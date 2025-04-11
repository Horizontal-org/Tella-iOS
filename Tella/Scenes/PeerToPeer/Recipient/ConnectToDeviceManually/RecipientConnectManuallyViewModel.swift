//
//  RecipientConnectManuallyViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//


import Foundation
import Combine
import UIKit

class RecipientConnectManuallyViewModel: ObservableObject {
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var ipAddress : String = ""
    @Published var pin: String = ""
    @Published var port: String = ""
   
    private var mainAppModel: MainAppModel?
    private var certificateManager : CertificateManager
    private var server: PeerToPeerServer
    let certificateFile = FileManager.tempDirectory(withFileName: "certificate.p12")
    var connectionInfo: ConnectionInfo?
    
    init(certificateManager : CertificateManager,
         mainAppModel:MainAppModel,
         server: PeerToPeerServer,
         connectionInfo:ConnectionInfo?) {
        
        self.certificateManager = certificateManager
        self.mainAppModel = mainAppModel
        self.server = server
        self.connectionInfo = connectionInfo
        
        initParameters()
    }
    
    func initParameters() {
        guard let connectionInfo else { return }
        self.pin = connectionInfo.pin
        self.ipAddress = connectionInfo.ipAddress
        self.port = "\(connectionInfo.port)"
    }
}
