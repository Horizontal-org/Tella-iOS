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
    
    private func isDebugAllowed(level requestedLevel: DebugLevel, space: DebugSpace) -> Bool {
        guard let allowedLevel = debugLevel[space] else {
            return false
        }
        return allowedLevel.rawValue <= requestedLevel.rawValue
    }
    
}
