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
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    static let shared = NetworkMonitor()
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let newStatus =  path.status == .satisfied
                self.isConnected = newStatus
                self.connectionDidChange.send(newStatus)
            }
        }
        monitor.start(queue: queue)
    }
    deinit {
        stopNetworkMonitoring()
    }
    
    func stopNetworkMonitoring() {
        self.monitor.cancel()
    }
    
}
