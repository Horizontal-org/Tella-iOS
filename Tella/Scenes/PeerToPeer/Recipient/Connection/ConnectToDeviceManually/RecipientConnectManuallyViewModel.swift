//
//  RecipientConnectManuallyViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine
import UIKit


class RecipientConnectManuallyViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
    @Published var viewState: RecipientConnectToDeviceViewAction = .none
    
    private var certificateGenerator : CertificateGenerator
    private var subscribers : Set<AnyCancellable> = []
   
    var mainAppModel: MainAppModel
    var server: PeerToPeerServer
    var connectionInfo: ConnectionInfo?

    init(certificateGenerator : CertificateGenerator,
         mainAppModel:MainAppModel,
         server: PeerToPeerServer,
         connectionInfo:ConnectionInfo?) {
        
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.server = server
        self.connectionInfo = connectionInfo
        
        initParameters()
        listenToRegisterPublisher()
    }
    
    func initParameters() {
        guard let connectionInfo else { return }
        self.pin = connectionInfo.pin
        self.ipAddress = connectionInfo.ipAddress
        self.port = "\(connectionInfo.port)"
    }
    
    func listenToRegisterPublisher() {
        self.server.didCancelAuthenticationPublisher
            .sink { value in
            self.viewState = .showVerificationHash
        }.store(in: &subscribers)
    }
    
}
