//
//  ConnectToDeviceManuallyViewModel.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
class ConnectToDeviceManuallyViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()

    init() {
        validateFields()
    }
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
    @Published var publicKey: String = ""
    @Published var valid : Bool = false
    @Published var validFields: Bool = false
    
    // Fields validation
    @Published var isValidIpAddress: Bool = false
    @Published var isValidPin: Bool = false
    @Published var isValidPort : Bool = false
    
    // Fields validation
    @Published var shouldShowIpAddressError: Bool = false
    @Published var shouldShowPinError: Bool = false

    func validateFields() {
        Publishers.CombineLatest3($isValidIpAddress, $isValidPin, $isValidPort)
            .map { ip, pin, port in
                return ip && pin && port
            }
            .assign(to: \.validFields, on: self)
            .store(in: &cancellables)
    }
    

}
