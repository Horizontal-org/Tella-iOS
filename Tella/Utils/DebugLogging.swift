import Foundation

/// Set debug level for a debug space
/// Default spaces: app, networking
///
/// - Warning: Should be used for Debug or Staging builds only
///
/// Usage:
///     setDebugLevel(level: .debug, for: .app)
///
/// - Parameter level: requested debug level
/// - Parameter space: space debug info is printed for
///
func setDebugLevel(level: DebugLevel?, for space: DebugSpace) {
    #if DEBUG || STAGING
        Logger.shared.debugLevel[space] = level
    #endif
}

enum DebugLevel: Int {
    case debug = 100
    case info = 200
    case error = 1000
}

enum DebugSpace: String {
    case app = "app"
    case files = "files"
    case crypto = "crypto"
}

func debugLog(_ error: Error, level: DebugLevel = .debug, space: DebugSpace = .app, function: String = #function) {
    debugLog("\(error.localizedDescription)", level: level, space: space, function: function)
}

func debugLog(_ debugText: String, level: DebugLevel = .debug, space: DebugSpace = .app, function: String = #function) {
    #if DEBUG || STAGING
        Logger.shared.log("\(function):\n\(debugText)\n", level: level, space: space)
    #endif
}
func debugLog(_ object: Any, level: DebugLevel = .debug, space: DebugSpace = .app, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
    #if DEBUG || STAGING
    let debugInfos = "FileName: \(Logger.sourceFileName(filePath: filename)) \nFunction Name: \(funcName) -> \(object)"
    Logger.shared.logDump(object, level: level, space: space,debugInfos: debugInfos)
    #endif
}

private class Logger {
    static let shared = Logger()
    
    fileprivate var debugLevel = [DebugSpace: DebugLevel]()
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    func log(_ debugText: String, level: DebugLevel, space: DebugSpace) {
        #if DEBUG || STAGING
        
        guard isDebugAllowed(level: level, space: space) else {
            return
        }
        print("\(debugText)")
        #endif
    }
    func logDump(_ debugObject: Any, level: DebugLevel, space: DebugSpace, debugInfos: String) {
        #if DEBUG || STAGING
            guard isDebugAllowed(level: level, space: space) else {
                return
            }
        let mirror = Mirror(reflecting: debugObject)
        var description = ""
        description += "{\n"
        for child in mirror.children {
            if let label = child.label {
                description += "  \(label): "
            }
            description += "\(child.value)\n"
        }
        description += "}"
        print("\(debugInfos):\n\(description)\n")
        #endif
    }
    
    private func isDebugAllowed(level requestedLevel: DebugLevel, space: DebugSpace) -> Bool {
        guard let allowedLevel = debugLevel[space] else {
            return false
        }
        return allowedLevel.rawValue <= requestedLevel.rawValue
    }

    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
}
