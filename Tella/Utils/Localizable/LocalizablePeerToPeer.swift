//
//  LocalizablePeerToPeer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//



enum LocalizablePeerToPeer: String, LocalizableDelegate {
    
    
    case peerToPeerAppBar = "PeerToPeer_AppBar"
    case nearbySharingSubhead = "PeerToPeer_NearbySharing_Subhead"
    case nearbySharingExpl = "PeerToPeer_NearbySharing_Expl"
    
    case sendFiles = "PeerToPeer_NearbySharing_SendFiles"
    case receiveFiles = "PeerToPeer_NearbySharing_ReceiveFiles"
    
    case learnMore = "PeerToPeer_NearbySharing_LearnMore"
    case getConnected = "PeerToPeer_Getconnected"
    case wifiConnectionDescription = "PeerToPeer_WifiConnection_Desc"
    case wifiConnectionTipsToConnect = "PeerToPeer_WifiConnection_TipsToConnect_Txt"
    case wifiConnectionTipsToConnectDescription = "PeerToPeer_WifiConnection_TipsToConnect_Desc"
    case currentWifi = "PeerToPeer_CurrentWifi"
    case wifiSameNetworkDescription = "PeerToPeer_SameNetworkDescription"
    case connectToDevice = "PeerToPeer_ConnectToDevice"
    case scanCode = "PeerToPeer_ScanCode"
    case showQrCode = "PeerToPeer_ShowQrCode"
    case havingTrouble = "PeerToPeer_HavingTrouble"
    case wifi = "PeerToPeer_Wifi"
    case connectManually = "PeerToPeer_ConnectManually"
    case enterDeviceInformation = "PeerToPeer_EnterDevice_Information"
    case ipAddress = "PeerToPeer_IpAddress"
    case pin = "PeerToPeer_Pin"
    case port = "PeerToPeer_Port"
    case publicKey = "PeerToPeer_PublicKey"
    case showDeviceInformation = "PeerToPeer_ShowDeviceInformation"
    case sendInputDesc = "PeerToPeer_ConnectToDevice_SenderInputDesc"
}
