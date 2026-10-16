//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CoreMotion
import UIKit

final class DeviceOrientationHelper: ObservableObject {
    static let shared = DeviceOrientationHelper()
    
    private let motionManager: CMMotionManager
    private var monitoringID: UUID?
    
    typealias DeviceOrientationHandler = ((_ deviceOrientation: UIDeviceOrientation) -> Void)?
    private var deviceOrientationAction: DeviceOrientationHandler = nil
    
    @Published var currentDeviceOrientation: UIDeviceOrientation = {
        let orientation = UIDevice.current.orientation
        return orientation.isValidInterfaceOrientation ? orientation : .portrait
    }()
    @Published var shouldAnimate: Bool = false
    
    private let motionLimit: Double = 0.6
    
    init() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
    
    func startDeviceOrientationNotifier(with handler: DeviceOrientationHandler = nil) {
        deviceOrientationAction = handler
        guard monitoringID == nil else { return }
        
        shouldAnimate = false
        let orientation = UIDevice.current.orientation
        if orientation.isValidInterfaceOrientation {
            currentDeviceOrientation = orientation
        }
        deviceOrientationAction?(currentDeviceOrientation)
        
        guard motionManager.isAccelerometerAvailable else { return }
        let monitoringID = UUID()
        self.monitoringID = monitoringID
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
            guard let self, self.monitoringID == monitoringID, let data else { return }
            
            let orientation: UIDeviceOrientation
            if data.acceleration.x >= self.motionLimit {
                orientation = .landscapeRight
            } else if data.acceleration.x <= -self.motionLimit {
                orientation = .landscapeLeft
            } else if data.acceleration.y <= -self.motionLimit {
                orientation = .portrait
            } else if data.acceleration.y >= self.motionLimit {
                orientation = .portraitUpsideDown
            } else {
                return
            }
            
            guard orientation != self.currentDeviceOrientation else { return }
            self.shouldAnimate = true
            self.currentDeviceOrientation = orientation
            self.deviceOrientationAction?(orientation)
        }
    }
    
    func stopDeviceOrientationNotifier() {
        // Ignore any callback queued by the old monitoring session, even after restarting.
        monitoringID = nil
        deviceOrientationAction = nil
        motionManager.stopAccelerometerUpdates()
    }
}
