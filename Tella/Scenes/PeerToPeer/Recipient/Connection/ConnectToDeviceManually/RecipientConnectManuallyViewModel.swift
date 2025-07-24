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
    var peerToPeerServer: PeerToPeerServer?
    var connectionInfo: ConnectionInfo?
    
    init(certificateGenerator : CertificateGenerator,
         mainAppModel:MainAppModel,
         connectionInfo:ConnectionInfo?) {
        
        self.certificateGenerator = certificateGenerator
        self.mainAppModel = mainAppModel
        self.peerToPeerServer = mainAppModel.peerToPeerServer
        self.connectionInfo = connectionInfo
        
        initParameters()
        listenToServerEvents()
    }
    
    func initParameters() {
        guard let connectionInfo else { return }
        self.pin = connectionInfo.pin
        self.ipAddress = connectionInfo.ipAddress
        self.port = "\(connectionInfo.port)"
    }
    
    func listenToServerEvents() {
        peerToPeerServer?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }

                switch event {
                case .verificationRequested:
                    self.viewState = .showVerificationHash
                default:
                    break
                }
            }
            .store(in: &subscribers)
    }

}
