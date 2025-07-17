//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    
    var connectionDidChange = PassthroughSubject<Bool,Never>()
    var isConnected : Bool = true
    var interfaceType  = PassthroughSubject<NWInterface.InterfaceType?, Never>()
    var interfaceTypeValue : NWInterface.InterfaceType? = nil
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    static let shared = NetworkMonitor()
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let newStatus =  path.status == .satisfied
                self.isConnected = newStatus
                self.connectionDidChange.send(newStatus)
                self.updateInterfaceType(for: path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateInterfaceType(for path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            debugLog("Connected via Wi-Fi")
            interfaceTypeValue = .wifi
            interfaceType.send(.wifi)
        } else if path.usesInterfaceType(.cellular) {
            debugLog("Connected via Cellular")
            interfaceTypeValue = .cellular
            interfaceType.send(.cellular)
        } else {
            debugLog("No active network connection")
            interfaceTypeValue = nil
            interfaceType.send(nil)
        }
    }
    
    deinit {
        stopNetworkMonitoring()
    }
    
    func stopNetworkMonitoring() {
        self.monitor.cancel()
    }
    
}
