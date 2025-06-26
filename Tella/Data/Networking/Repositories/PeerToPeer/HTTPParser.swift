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
    
    private var method = ""
    private var url = ""
    private var endpoint = ""
    private var contentLength: Int?
    private var contentTypeString: String?
    private var currentHeaderField: String?
    private var remainingBodyData: Int = 0
    private var body = ""
    private var bodyFullyReceived: Bool = false
    
    
    var queryParametersAreVerified : Bool = false
    
    var fileHandle: FileHandle?
    var fileURL: URL?
    
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
            return 0
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
                    instance.createTempFile()
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
            
            return 0
        }
        
        settings.on_message_complete = { parser in
            
            let instance = Unmanaged<HTTPParser>.fromOpaque(parser!.pointee.data).takeUnretainedValue()
            debugLog("on_message_complete")
            instance.bodyFullyReceived = true
            instance.remainingBodyData = 0
            return 0
        }
        
        llhttp_init(&parser, HTTP_REQUEST, &settings)
        parser.data = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
    
    func parse(data: Data) throws -> HTTPRequest {
        guard data.count <= UInt32.max else {
            throw RuntimeError("Request too large")
        }
        
        let result = data.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) in
            return llhttp_execute(&parser, ptr.bindMemory(to: Int8.self).baseAddress, data.count)
        }
        
        if result != HPE_OK  {
            throw RuntimeError("Parse error")
        }
        
        guard let methodCString = llhttp_method_name(llhttp_method(rawValue: UInt32(parser.method))),
              let urlComponents = URLComponents(string: url) else {
            throw RuntimeError("Invalid request")
        }
        
        var queryParams: [String: String] = [:]
        if let items = urlComponents.queryItems {
            for item in items {
                queryParams[item.name] = item.value ?? ""
            }
        }
        
        if let expected = contentLength {
            remainingBodyData = abs(expected - body.count)
        }
        
        return HTTPRequest(
            method: String(cString: methodCString),
            endpoint: urlComponents.path,
            queryParameters: queryParams,
            headers: Headers(contentLength: contentLength, contentType: contentTypeString),
            body: body,
            remainingBodyData: remainingBodyData,
            bodyFullyReceived: bodyFullyReceived
        )
    }
    
    private func createTempFile() {
        let tempDir = FileManager.default.temporaryDirectory
        let uniqueFileName = UUID().uuidString
        let url = tempDir.appendingPathComponent(uniqueFileName).appendingPathExtension("heic")
        
        do {
            try Data().write(to: url, options: .atomic)
            self.fileHandle = try FileHandle(forUpdating: url)
            self.fileURL = url
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
