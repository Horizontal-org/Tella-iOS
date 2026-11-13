//
//  AVCapturePhotoExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import AVFoundation
import CoreImage
import CoreVideo
import ImageIO
import UniformTypeIdentifiers

extension AVCapturePhoto {
    
    private static let photoContext = CIContext(options: [.cacheIntermediates: false])
    
    func saveImage(to url: URL,
                   shouldPreserveMetadata: Bool,
                   aspectRatio: CGFloat) throws {
        guard let image = cgImageRepresentation() else {
            debugLog("Failed to prepare camera photo pixels.")
            throw CocoaError(.fileWriteUnknown)
        }
        
        let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let crop = CameraAspectRatio.cropRect(width: image.width, height: image.height, portraitAspectRatio: aspectRatio)
        if crop == bounds, let original = originalHEIC(shouldPreserveMetadata: shouldPreserveMetadata) {
            try original.write(to: url)
            return
        }
        
        guard let outputImage = crop == bounds ? image : image.cropping(to: crop) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let orientationKey = kCGImagePropertyOrientation as String
        var properties = shouldPreserveMetadata ? metadata : [:]
        properties[orientationKey] = metadata[orientationKey] ?? CGImagePropertyOrientation.up.rawValue
        properties[kCGImagePropertyPixelWidth as String] = outputImage.width
        properties[kCGImagePropertyPixelHeight as String] = outputImage.height
        
        let exifKey = kCGImagePropertyExifDictionary as String
        if var exif = properties[exifKey] as? [String: Any] {
            exif[kCGImagePropertyExifPixelXDimension as String] = outputImage.width
            exif[kCGImagePropertyExifPixelYDimension as String] = outputImage.height
            properties[exifKey] = exif
        }
        
        if crop != bounds, let data = fileDataRepresentation(),
           let hdr = try Self.croppedHDR(data, bounds: bounds, crop: crop, properties: properties) {
            try hdr.write(to: url)
            return
        }
        
        let imageData = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(imageData as CFMutableData,
                                                                 UTType.heic.identifier as CFString,
                                                                 1, nil) else {
            debugLog("Failed to create image destination.")
            throw CocoaError(.fileWriteUnknown)
        }
        
        CGImageDestinationAddImage(destination, outputImage, properties as CFDictionary)
        guard CGImageDestinationFinalize(destination) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try (imageData as Data).write(to: url)
    }
    
    private func originalHEIC(shouldPreserveMetadata: Bool) -> Data? {
        guard let data = fileDataRepresentation(),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(source), type as String == UTType.heic.identifier else {
            return nil
        }
        if shouldPreserveMetadata { return data }
        
        let index = CGImageSourceGetPrimaryImageIndex(source)
        let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any] ?? metadata
        return fileDataRepresentation(with: PhotoDisplayMetadata(source: properties))
    }
    
    private static func croppedHDR(_ data: Data, bounds: CGRect, crop: CGRect,
                                   properties: [String: Any]) throws -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let index = CGImageSourceGetPrimaryImageIndex(source)
        let legacyMap = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, index, kCGImageAuxiliaryDataTypeHDRGainMap)
        let isoMap: [String: Any]?
        if #available(iOS 18.0, *) {
            isoMap = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, index, kCGImageAuxiliaryDataTypeISOGainMap) as? [String: Any]
        } else {
            isoMap = nil
        }
        guard legacyMap != nil || isoMap != nil else { return nil }
        
        let readOptions: [CIImageOption: Any] = [.applyOrientationProperty: false]
        guard let base = CIImage(data: data, options: readOptions), base.extent.size == bounds.size,
              let colorSpace = base.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB) else {
            throw CocoaError(.fileWriteUnknown)
        }
        
        // Convert the crop from CGImage's top-left origin to Core Image's bottom-left origin.
        let frame = CGRect(x: base.extent.minX + crop.minX, y: base.extent.maxY - crop.maxY,
                           width: crop.width, height: crop.height)
        let toOrigin = CGAffineTransform(translationX: -frame.minX, y: -frame.minY)
        var outputProperties = properties
        var options: [CIImageRepresentationOption: Any] = [:]
        let outputMapType: CFString
        var legacyHDRValues: [String: NSNumber]?
        if #available(iOS 18.0, *), let isoMap {
            guard let hdr = CIImage(data: data, options: [.applyOrientationProperty: false, .expandToHDR: true]) else {
                throw CocoaError(.fileWriteUnknown)
            }
            options[.hdrImage] = hdr.cropped(to: frame).transformed(by: toOrigin)
            let description = isoMap[kCGImageAuxiliaryDataInfoDataDescription as String] as? [String: Any]
            let pixelFormat = description?[kCGImagePropertyPixelFormat as String] as? OSType
            options[.hdrGainMapAsRGB] = pixelFormat != kCVPixelFormatType_OneComponent8
            outputMapType = kCGImageAuxiliaryDataTypeISOGainMap
        } else {
            guard let map = CIImage(data: data, options: [.applyOrientationProperty: false, .auxiliaryHDRGainMap: true]) else {
                throw CocoaError(.fileWriteUnknown)
            }
            let sourceProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [String: Any] ?? [:]
            let makerKey = kCGImagePropertyMakerAppleDictionary as String
            legacyHDRValues = PhotoDisplayMetadata.hdrValues(in: sourceProperties)
            if let values = legacyHDRValues {
                var maker = outputProperties[makerKey] as? [String: Any] ?? [:]
                maker.merge(values) { _, value in value }
                outputProperties[makerKey] = maker
            }
            options[.hdrGainMapImage] = cropGainMap(map, frame: frame, baseExtent: base.extent)
            outputMapType = kCGImageAuxiliaryDataTypeHDRGainMap
        }
        
        let image = base.cropped(to: frame).transformed(by: toOrigin).settingProperties(outputProperties)
        guard let result = photoContext.heifRepresentation(of: image, format: .RGBA8, colorSpace: colorSpace, options: options),
              let encoded = CGImageSourceCreateWithData(result as CFData, nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let encodedIndex = CGImageSourceGetPrimaryImageIndex(encoded)
        guard CGImageSourceCopyAuxiliaryDataInfoAtIndex(encoded, encodedIndex, outputMapType) != nil else {
            throw CocoaError(.fileWriteUnknown)
        }
        if let legacyHDRValues {
            let encodedProperties = CGImageSourceCopyPropertiesAtIndex(encoded, encodedIndex, nil) as? [String: Any] ?? [:]
            guard PhotoDisplayMetadata.hdrValues(in: encodedProperties) == legacyHDRValues else {
                throw CocoaError(.fileWriteUnknown)
            }
        }
        return result
    }
    
    private static func cropGainMap(_ map: CIImage, frame: CGRect, baseExtent: CGRect) -> CIImage {
        let scaleX = map.extent.width / baseExtent.width
        let scaleY = map.extent.height / baseExtent.height
        let crop = CGRect(x: map.extent.minX + (frame.minX - baseExtent.minX) * scaleX,
                          y: map.extent.minY + (frame.minY - baseExtent.minY) * scaleY,
                          width: frame.width * scaleX, height: frame.height * scaleY)
        let output = CGRect(x: 0, y: 0, width: max(1, crop.width.rounded()), height: max(1, crop.height.rounded()))
        return map.transformed(by: CGAffineTransform(translationX: -crop.minX, y: -crop.minY))
            .transformed(by: CGAffineTransform(scaleX: output.width / crop.width, y: output.height / crop.height))
            .cropped(to: output)
            .settingProperties(map.properties)
    }
}

private final class PhotoDisplayMetadata: NSObject, AVCapturePhotoFileDataRepresentationCustomizer {
    private let properties: [String: Any]
    
    init(source: [String: Any]) {
        let orientationKey = kCGImagePropertyOrientation as String
        let makerKey = kCGImagePropertyMakerAppleDictionary as String
        var properties = [orientationKey: source[orientationKey] ?? CGImagePropertyOrientation.up.rawValue]
        
        properties[makerKey] = Self.hdrValues(in: source)
        self.properties = properties
    }
    
    static func hdrValues(in source: [String: Any]) -> [String: NSNumber]? {
        // Apple's gain map needs these two numbers to reconstruct the HDR brightness range.
        guard let maker = source[kCGImagePropertyMakerAppleDictionary as String] as? [String: Any],
              let gain = maker["33"] as? NSNumber, let headroom = maker["48"] as? NSNumber else { return nil }
        return ["33": gain, "48": headroom]
    }
    
    func replacementMetadata(for photo: AVCapturePhoto) -> [String: Any]? {
        properties
    }
}
