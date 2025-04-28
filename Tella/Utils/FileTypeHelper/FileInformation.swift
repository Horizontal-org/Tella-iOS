//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


public enum FileType : String {
    case heic
    case amr
    case ar
    case avi
    case bmp
    case bz2
    case cab
    case cr2
    case crx
    case deb
    case dmg
    case eot
    case epub
    case exe
    case flac
    case flif
    case flv
    case gif
    case gz
    case ico
    case jpg
    case jxr
    case lz
    case m4a
    case m4v
    case mid
    case mov
    case mp3
    case mp4
    case mpg
    case msi
    case mxf
    case nes
    case ogg
    case opus
    case otf
    case pdf
    case png
    case ps
    case psd
    case rar
    case rpm
    case rtf
    case sevenZ
    case sqlite
    case swf
    case tar
    case tif
    case ttf
    case wav
    case webp
    case wmv
    case woff
    case woff2
    case xpi
    case xz
    case z
    case zip
    
}

public struct FileInformation {
    
    public let mimeType: String
    
    public let fileExtension: String
    
    public let type: FileType
    
    fileprivate let bytesCount: Int
    
    fileprivate let matches: ([UInt8]) -> Bool
    
    public func matches(bytes: [UInt8]) -> Bool {
        return bytes.count >= bytesCount && matches(bytes)
    }
    
    /// List of all supported `FileInformation`s
    public static let all: [FileInformation] = [
        
        FileInformation(mimeType: "image/heic",
                        fileExtension: "heic",
                        type: .heic,
                        bytesCount: 8,
                        matches: { bytes in
                            return (bytes[0...2] == [0x00, 0x00, 0x00] && (bytes[3] == 0x18 || bytes[3] == 0x28 || bytes[3] == 0x24) && bytes[4...7] == [0x66, 0x74, 0x79, 0x70])
                        }
                       ),
        
        
        FileInformation(mimeType: "image/jpeg",
                        fileExtension: "jpg",
                        type: .jpg,
                        bytesCount: 3,
                        matches: { bytes in
                            return bytes[0...2] == [0xFF, 0xD8, 0xFF]
                        }
                       ),
        
        FileInformation(mimeType: "image/png",
                        fileExtension: "png",
                        type: .png,
                        bytesCount: 4,
                        matches: { bytes in
                            return bytes[0...3] == [0x89, 0x50, 0x4E, 0x47]
                        }
                       ),
        FileInformation(
            mimeType: "image/gif",
            fileExtension: "gif",
            type: .gif,
            bytesCount: 3,
            matches: {  bytes  in
                return bytes[0...2] == [0x47, 0x49, 0x46]
            }
        ),
        FileInformation(
            mimeType: "image/webp",
            fileExtension: "webp",
            type: .webp,
            bytesCount: 12,
            matches: {  bytes  in
                return bytes[8...11] == [0x57, 0x45, 0x42, 0x50]
            }
        ),
        FileInformation(
            mimeType: "image/flif",
            fileExtension: "flif",
            type: .flif,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x46, 0x4C, 0x49, 0x46]
            }
        ),
        FileInformation(
            mimeType: "image/x-canon-cr2",
            fileExtension: "cr2",
            type: .cr2,
            bytesCount: 10,
            matches: {  bytes  in
                return (bytes[0...3] == [0x49, 0x49, 0x2A, 0x00] || bytes[0...3] == [0x4D, 0x4D, 0x00, 0x2A]) &&
                (bytes[8...9] == [0x43, 0x52])
            }
        ),
        FileInformation(
            mimeType: "image/tiff",
            fileExtension: "tif",
            type: .tif,
            bytesCount: 4,
            matches: {  bytes  in
                return (bytes[0...3] == [0x49, 0x49, 0x2A, 0x00]) ||
                (bytes[0...3] == [0x4D, 0x4D, 0x00, 0x2A])
            }
        ),
        FileInformation(
            mimeType: "image/bmp",
            fileExtension: "bmp",
            type: .bmp,
            bytesCount: 2,
            matches: {  bytes  in
                return bytes[0...1] == [0x42, 0x4D]
            }
        ),
        FileInformation(
            mimeType: "image/vnd.ms-photo",
            fileExtension: "jxr",
            type: .jxr,
            bytesCount: 3,
            matches: {  bytes  in
                return bytes[0...2] == [0x49, 0x49, 0xBC]
            }
        ),
        FileInformation(
            mimeType: "image/vnd.adobe.photoshop",
            fileExtension: "psd",
            type: .psd,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x38, 0x42, 0x50, 0x53]
            }
        ),
        FileInformation(
            mimeType: "application/epub+zip",
            fileExtension: "epub",
            type: .epub,
            bytesCount: 58,
            matches: {  bytes  in
                return (bytes[0...3] == [0x50, 0x4B, 0x03, 0x04]) &&
                (bytes[30...57] == [
                    0x6D, 0x69, 0x6D, 0x65, 0x74, 0x79, 0x70, 0x65, 0x61, 0x70, 0x70, 0x6C,
                    0x69, 0x63, 0x61, 0x74, 0x69, 0x6F, 0x6E, 0x2F, 0x65, 0x70, 0x75, 0x62,
                    0x2B, 0x7A, 0x69, 0x70
                ])
            }
        ),
        
        FileInformation(
            mimeType: "application/zip",
            fileExtension: "zip",
            type: .zip,
            bytesCount: 50,
            matches: {  bytes  in
                return (bytes[0...1] == [0x50, 0x4B]) &&
                (bytes[2] == 0x3 || bytes[2] == 0x5 || bytes[2] == 0x7) &&
                (bytes[3] == 0x4 || bytes[3] == 0x6 || bytes[3] == 0x8)
            }
        ),
        FileInformation(
            mimeType: "application/x-tar",
            fileExtension: "tar",
            type: .tar,
            bytesCount: 262,
            matches: {  bytes  in
                return bytes[257...261] == [0x75, 0x73, 0x74, 0x61, 0x72]
            }
        ),
        FileInformation(
            mimeType: "application/x-rar-compressed",
            fileExtension: "rar",
            type: .rar,
            bytesCount: 7,
            matches: {  bytes  in
                return (bytes[0...5] == [0x52, 0x61, 0x72, 0x21, 0x1A, 0x07]) &&
                (bytes[6] == 0x0 || bytes[6] == 0x1)
            }
        ),
        FileInformation(
            mimeType: "application/gzip",
            fileExtension: "gz",
            type: .gz,
            bytesCount: 3,
            matches: {  bytes  in
                return bytes[0...2] == [0x1F, 0x8B, 0x08]
            }
        ),
        FileInformation(
            mimeType: "application/x-bzip2",
            fileExtension: "bz2",
            type: .bz2,
            bytesCount: 3,
            matches: {  bytes  in
                return bytes[0...2] == [0x42, 0x5A, 0x68]
            }
        ),
        FileInformation(
            mimeType: "application/x-7z-compressed",
            fileExtension: "7z",
            type: .sevenZ,
            bytesCount: 6,
            matches: {  bytes  in
                return bytes[0...5] == [0x37, 0x7A, 0xBC, 0xAF, 0x27, 0x1C]
            }
        ),
        FileInformation(
            mimeType: "application/x-apple-diskimage",
            fileExtension: "dmg",
            type: .dmg,
            bytesCount: 2,
            matches: {  bytes  in
                return bytes[0...1] == [0x78, 0x01]
            }
        ),
        FileInformation(
            mimeType: "video/mp4",
            fileExtension: "mp4",
            type: .mp4,
            bytesCount: 28,
            matches: {  bytes  in
                return (bytes[0...2] == [0x00, 0x00, 0x00] && (bytes[3] == 0x18 || bytes[3] == 0x20) && bytes[4...7] == [0x66, 0x74, 0x79, 0x70]) ||
                (bytes[0...3] == [0x33, 0x67, 0x70, 0x35]) ||
                (bytes[0...11] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32] &&
                 bytes[16...27] == [0x6D, 0x70, 0x34, 0x31, 0x6D, 0x70, 0x34, 0x32, 0x69, 0x73, 0x6F, 0x6D]) ||
                (bytes[0...11] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x69, 0x73, 0x6F, 0x6D]) ||
                (bytes[0...11] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x6D, 0x70, 0x34, 0x32, 0x00, 0x00, 0x00, 0x00])
            }
        ),
        FileInformation(
            mimeType: "video/x-m4v",
            fileExtension: "m4v",
            type: .m4v,
            bytesCount: 11,
            matches: {  bytes  in
                return bytes[0...10] == [0x00, 0x00, 0x00, 0x1C, 0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x56]
            }
        ),
        FileInformation(
            mimeType: "audio/midi",
            fileExtension: "mid",
            type: .mid,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x4D, 0x54, 0x68, 0x64]
            }
        ),
        
        FileInformation(
            mimeType: "video/quicktime",
            fileExtension: "mov",
            type: .mov,
            bytesCount: 8,
            matches: {  bytes  in
                return bytes[0...7] == [0x00, 0x00, 0x00, 0x14, 0x66, 0x74, 0x79, 0x70]
            }
        ),
        FileInformation(
            mimeType: "video/x-msvideo",
            fileExtension: "avi",
            type: .avi,
            bytesCount: 11,
            matches: {  bytes  in
                return (bytes[0...3] == [0x52, 0x49, 0x46, 0x46]) &&
                (bytes[8...10] == [0x41, 0x56, 0x49])
            }
        ),
        FileInformation(
            mimeType: "video/x-ms-wmv",
            fileExtension: "wmv",
            type: .wmv,
            bytesCount: 10,
            matches: {  bytes  in
                return bytes[0...9] == [0x30, 0x26, 0xB2, 0x75, 0x8E, 0x66, 0xCF, 0x11, 0xA6, 0xD9]
            }
        ),
        FileInformation(
            mimeType: "video/mpeg",
            fileExtension: "mpg",
            type: .mpg,
            bytesCount: 4,
            matches: {  bytes  in
                guard bytes[0...2] == [0x00, 0x00, 0x01]  else {
                    return false
                }
                
                let hexCode = String(format: "%2X", bytes[3])
                
                return hexCode.first != nil && hexCode.first! == "B"
            }
        ),
        FileInformation(
            mimeType: "audio/mpeg",
            fileExtension: "mp3",
            type: .mp3,
            bytesCount: 3,
            matches: {  bytes  in
                return (bytes[0...2] == [0x49, 0x44, 0x33]) ||
                (bytes[0...1] == [0xFF, 0xFB])
            }
        ),
        FileInformation(
            mimeType: "audio/m4a",
            fileExtension: "m4a",
            type: .m4a,
            bytesCount: 11,
            matches: {  bytes  in
                return (bytes[0...3] == [0x4D, 0x34, 0x41, 0x20]) ||
                (bytes[4...10] == [0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41])
            }
        ),
        
        FileInformation(
            mimeType: "audio/opus",
            fileExtension: "opus",
            type: .opus,
            bytesCount: 36,
            matches: {  bytes  in
                return bytes[28...35] == [0x4F, 0x70, 0x75, 0x73, 0x48, 0x65, 0x61, 0x64]
            }
        ),
        FileInformation(
            mimeType: "audio/ogg",
            fileExtension: "ogg",
            type: .ogg,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x4F, 0x67, 0x67, 0x53]
            }
        ),
        FileInformation(
            mimeType: "audio/x-flac",
            fileExtension: "flac",
            type: .flac,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x66, 0x4C, 0x61, 0x43]
            }
        ),
        FileInformation(
            mimeType: "audio/x-wav",
            fileExtension: "wav",
            type: .wav,
            bytesCount: 12,
            matches: {  bytes  in
                return (bytes[0...3] == [0x52, 0x49, 0x46, 0x46]) &&
                (bytes[8...11] == [0x57, 0x41, 0x56, 0x45])
            }
        ),
        FileInformation(
            mimeType: "audio/amr",
            fileExtension: "amr",
            type: .amr,
            bytesCount: 6,
            matches: {  bytes  in
                return bytes[0...5] == [0x23, 0x21, 0x41, 0x4D, 0x52, 0x0A]
            }
        ),
        FileInformation(
            mimeType: "application/pdf",
            fileExtension: "pdf",
            type: .pdf,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x25, 0x50, 0x44, 0x46]
            }
        ),
        FileInformation(
            mimeType: "application/x-msdownload",
            fileExtension: "exe",
            type: .exe,
            bytesCount: 2,
            matches: {  bytes  in
                return bytes[0...1] == [0x4D, 0x5A]
            }
        ),
        FileInformation(
            mimeType: "application/x-shockwave-flash",
            fileExtension: "swf",
            type: .swf,
            bytesCount: 3,
            matches: {  bytes  in
                return (bytes[0] == 0x43 || bytes[0] == 0x46) && (bytes[1...2] == [0x57, 0x53])
            }
        ),
        FileInformation(
            mimeType: "application/rtf",
            fileExtension: "rtf",
            type: .rtf,
            bytesCount: 5,
            matches: {  bytes  in
                return bytes[0...4] == [0x7B, 0x5C, 0x72, 0x74, 0x66]
            }
        ),
        FileInformation(
            mimeType: "application/font-woff",
            fileExtension: "woff",
            type: .woff,
            bytesCount: 8,
            matches: {  bytes  in
                return (bytes[0...3] == [0x77, 0x4F, 0x46, 0x46]) &&
                ((bytes[4...7] == [0x00, 0x01, 0x00, 0x00]) || (bytes[4...7] == [0x4F, 0x54, 0x54, 0x4F]))
            }
        ),
        FileInformation(
            mimeType: "application/font-woff",
            fileExtension: "woff2",
            type: .woff2,
            bytesCount: 8,
            matches: {  bytes  in
                return (bytes[0...3] == [0x77, 0x4F, 0x46,  0x32]) &&
                ((bytes[4...7] == [0x00, 0x01, 0x00, 0x00]) || (bytes[4...7] == [0x4F, 0x54, 0x54, 0x4F]))
            }
        ),
        FileInformation(
            mimeType: "application/octet-stream",
            fileExtension: "eot",
            type: .eot,
            bytesCount: 11,
            matches: {  bytes  in
                return (bytes[34...35] == [0x4C, 0x50]) &&
                ((bytes[8...10] == [0x00, 0x00, 0x01]) || (bytes[8...10] == [0x01, 0x00, 0x02]) || (bytes[8...10] == [0x02, 0x00, 0x02]))
            }
        ),
        FileInformation(
            mimeType: "application/font-sfnt",
            fileExtension: "ttf",
            type: .ttf,
            bytesCount: 5,
            matches: {  bytes  in
                return bytes[0...4] == [0x00, 0x01, 0x00, 0x00, 0x00]
            }
        ),
        FileInformation(
            mimeType: "application/font-sfnt",
            fileExtension: "otf",
            type: .otf,
            bytesCount: 5,
            matches: {  bytes  in
                return bytes[0...4] == [0x4F, 0x54, 0x54, 0x4F, 0x00]
            }
        ),
        FileInformation(
            mimeType: "image/x-icon",
            fileExtension: "ico",
            type: .ico,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x00, 0x00, 0x01, 0x00]
            }
        ),
        FileInformation(
            mimeType: "video/x-flv",
            fileExtension: "flv",
            type: .flv,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x46, 0x4C, 0x56, 0x01]
            }
        ),
        FileInformation(
            mimeType: "application/postscript",
            fileExtension: "ps",
            type: .ps,
            bytesCount: 2,
            matches: {  bytes  in
                return bytes[0...1] == [0x25, 0x21]
            }
        ),
        FileInformation(
            mimeType: "application/x-xz",
            fileExtension: "xz",
            type: .xz,
            bytesCount: 6,
            matches: {  bytes  in
                return bytes[0...5] == [0xFD, 0x37, 0x7A, 0x58, 0x5A, 0x00]
            }
        ),
        FileInformation(
            mimeType: "application/x-sqlite3",
            fileExtension: "sqlite",
            type: .sqlite,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x53, 0x51, 0x4C, 0x69]
            }
        ),
        FileInformation(
            mimeType: "application/x-nintendo-nes-rom",
            fileExtension: "nes",
            type: .nes,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x4E, 0x45, 0x53, 0x1A]
            }
        ),
        FileInformation(
            mimeType: "application/x-google-chrome-extension",
            fileExtension: "crx",
            type: .crx,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x43, 0x72, 0x32, 0x34]
            }
        ),
        FileInformation(
            mimeType: "application/vnd.ms-cab-compressed",
            fileExtension: "cab",
            type: .cab,
            bytesCount: 4,
            matches: {  bytes  in
                return (bytes[0...3] == [0x4D, 0x53, 0x43, 0x46]) || (bytes[0...3] == [0x49, 0x53, 0x63, 0x28])
            }
        ),
        
        FileInformation(
            mimeType: "application/x-deb",
            fileExtension: "deb",
            type: .deb,
            bytesCount: 21,
            matches: {  bytes  in
                return bytes[0...20] == [
                    0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E, 0x0A, 0x64, 0x65, 0x62, 0x69,
                    0x61, 0x6E, 0x2D, 0x62, 0x69, 0x6E, 0x61, 0x72, 0x79
                ]
            }
        ),
        FileInformation(
            mimeType: "application/x-unix-archive",
            fileExtension: "ar",
            type: .ar,
            bytesCount: 7,
            matches: {  bytes  in
                return bytes[0...6] == [0x21, 0x3C, 0x61, 0x72, 0x63, 0x68, 0x3E]
            }
        ),
        FileInformation(
            mimeType: "application/x-rpm",
            fileExtension: "rpm",
            type: .rpm,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0xED, 0xAB, 0xEE, 0xDB]
            }
        ),
        FileInformation(
            mimeType: "application/x-compress",
            fileExtension: "Z",
            type: .z,
            bytesCount: 2,
            matches: {  bytes  in
                return (bytes[0...1] == [0x1F, 0xA0]) || (bytes[0...1] == [0x1F, 0x9D])
            }
        ),
        FileInformation(
            mimeType: "application/x-lzip",
            fileExtension: "lz",
            type: .lz,
            bytesCount: 4,
            matches: {  bytes  in
                return bytes[0...3] == [0x4C, 0x5A, 0x49, 0x50]
            }
        ),
        FileInformation(
            mimeType: "application/x-msi",
            fileExtension: "msi",
            type: .msi,
            bytesCount: 8,
            matches: {  bytes  in
                return bytes[0...7] == [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1]
            }
        ),
        FileInformation(
            mimeType: "application/mxf",
            fileExtension: "mxf",
            type: .mxf,
            bytesCount: 14,
            matches: {  bytes  in
                return bytes[0...13] == [0x06, 0x0E, 0x2B, 0x34, 0x02, 0x05, 0x01, 0x01, 0x0D, 0x01, 0x02, 0x01, 0x01, 0x02 ]
            }
        )
    ]
}
