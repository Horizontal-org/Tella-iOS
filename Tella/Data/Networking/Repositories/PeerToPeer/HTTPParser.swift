//
//  HTTPParser.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

final class HTTPParser {
    
    private var parser = llhttp_t()
    private var settings = llhttp_settings_t()
    private var url = ""
    private var endpoint = ""
    private var contentLength: Int?
    private var contentTypeString: String?
    private var currentHeaderField: String?
    private var body = ""
    
    var bodyFullyReceived: Bool = false
    var parserIsPaused: Bool = false
    
    var queryParametersAreVerified : Bool = false
    
    var fileHandle: FileHandle?
    var fileURL: URL?
    var pausedData: Data?
    
    var method: String?
    var queryParameters: [String:String] = [:]
    var headers: Headers?
    
    var onReceiveBody: (() -> Void)?
    
    var request: HTTPRequest {
        return HTTPRequest(
            endpoint: endpoint,
            queryParameters: queryParameters,
            headers: Headers(contentLength: contentLength, contentType: contentTypeString),
            body: body,
            bodyFullyReceived: bodyFullyReceived
        )
    }
    var contentType: ContentType? {
        return ContentType(rawValue:  contentTypeString ?? "")
    }
    
    init() {
        
        llhttp_settings_init(&settings)
        
        settings.on_url = { parser, at, length in
            guard let at = at else { return 0 }
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser!.pointee.data).takeUnretainedValue()
            let value = String(decoding: UnsafeBufferPointer(start: UnsafeRawPointer(at).assumingMemoryBound(to: UInt8.self), count: length), as: UTF8.self)
            instance.url += value
            
            if let urlComponents = URLComponents(string: instance.url) {
                
                instance.endpoint = urlComponents.path
                var queryParams: [String: String] = [:]
                if let items = urlComponents.queryItems {
                    for item in items {
                        queryParams[item.name] = item.value ?? ""
                    }
                }
                instance.queryParameters = queryParams
            }
            
            if instance.queryParameters.isEmpty {
                return 0
            } else {
                instance.parserIsPaused = true
                return Int32(HPE_PAUSED.rawValue)
            }
        }
        
        settings.on_header_field = { parser, at, length in
            guard let at = at else { return 0 }
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser!.pointee.data).takeUnretainedValue()
            let value = String(decoding: UnsafeBufferPointer(start: UnsafeRawPointer(at).assumingMemoryBound(to: UInt8.self), count: length), as: UTF8.self)
            instance.currentHeaderField = value
            return 0
        }
        
        settings.on_header_value = { parser, at, length in
            guard let at = at else { return 0 }
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser!.pointee.data).takeUnretainedValue()
            let value = String(decoding: UnsafeBufferPointer(start: UnsafeRawPointer(at).assumingMemoryBound(to: UInt8.self), count: length), as: UTF8.self)
            if let key = instance.currentHeaderField {
                if key == HTTPHeaderField.contentLength.rawValue {
                    instance.contentLength = Int(value)
                    
                    
                } else if key == HTTPHeaderField.contentType.rawValue {
                    instance.contentTypeString = value
                }
                instance.currentHeaderField = nil
            }
            
            
            return 0
        }
        
        settings.on_body = { parser, at, length in
            
            guard let parser = parser, let at = at else { return 0 }
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser.pointee.data).takeUnretainedValue()
            
            let buffer = UnsafeBufferPointer(
                start: UnsafeRawPointer(at).assumingMemoryBound(to: UInt8.self),
                count: length
            )
            
            let contentType = ContentType(rawValue: instance.contentTypeString ?? "")
            switch contentType {
            case .json:
                let value = String(decoding: buffer, as: UTF8.self)
                instance.body += value
            case .data:
                if instance.fileHandle == nil {
                    instance.createFileHandle()
                }
                do {
                    try instance.fileHandle?.seekToEnd()
                    try instance.fileHandle?.write(contentsOf: buffer)
                    debugLog("Wrote data chunk to file")
                } catch {
                    debugLog("Write error: \(error)")
                }
            default:
                break
            }
            instance.onReceiveBody?()
            
            return 0
        }
        
        settings.on_message_complete = { parser in
            
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser!.pointee.data).takeUnretainedValue()
            instance.bodyFullyReceived = true
            instance.onComplete?()
            debugLog("on_message_complete")
            return 0
        }
        
        llhttp_init(&parser, HTTP_REQUEST, &settings)
        parser.data = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func parse(data: Data) throws {
        guard data.count <= UInt32.max else {
            throw RuntimeError("Request too large")
        }
        
        let result = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            return llhttp_execute(&parser, ptr.bindMemory(to: Int8.self).baseAddress, data.count)
        }
        
        if result ==  HPE_PAUSED  {
            let errorPos = llhttp_get_error_pos(&parser)
            
            // Calculate offset using pointer arithmetic
            let dataStart = data.withUnsafeBytes { $0.baseAddress!.assumingMemoryBound(to: Int8.self) }
            let consumed = dataStart.distance(to: errorPos!)
            
            if consumed < data.count {
                pausedData = data.subdata(in: consumed..<data.count)
            } else {
                pausedData = nil
            }
            return
        }
        
        if result != HPE_OK  {
            throw RuntimeError("Parse error")
        }
    }
    
    func resumeParsing() throws {
        parserIsPaused = false
        
        guard let data = pausedData else { return }
        
        let result = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            llhttp_resume(&parser)
            return llhttp_execute(&parser, ptr.bindMemory(to: Int8.self).baseAddress, data.count)
        }
        
        pausedData = nil
        
        if result != HPE_OK {
            throw RuntimeError("Resume parse error")
        }
    }
    
    private func createFileHandle() {
        do {
            guard let fileURL  else { return  }
            try Data().write(to: fileURL, options: .atomic)
            self.fileHandle = try FileHandle(forUpdating: fileURL)
        } catch {
            debugLog("Failed to create temp file: \(error)")
        }
    }
    
    func closeFile() {
        do {
            try fileHandle?.close()
        } catch {
            debugLog("Error closing file: \(error)")
        }
        fileHandle = nil
    }
    
    deinit {
        closeFile()
    }
}
