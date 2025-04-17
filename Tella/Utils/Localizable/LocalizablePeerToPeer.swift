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
    case locationAccess = "PeerToPeer_LocationAccess"
    case detectWifiSettingsDesc = "PeerToPeer_WifiSettingsDesc"
    case cancel = "PeerToPeer_Cancel"
    case settings = "PeerToPeer_Settings"
    case noConnection = "PeerToPeer_NoConnection"
    case waitingForSenderDesc = "PeerToPeer_WaitingForSenderDesc"
    case senderRequestFilesNumberDesc = "PeerToPeer_SenderRequest_NumberOfFiles_Desc"
    case requestQuestion = "PeerToPeer_RequestQuestion"
    case accept = "PeerToPeer_Accept"
    case reject = "PeerToPeer_Reject"
    case invalidIpAddress = "PeerToPeer_InvalidIpAddress"
    case invalidPin = "PeerToPeer_InvalidPin"
    case selectFilesToSend = "PeerToPeer_SelectFilesToSend"
    case title = "PeerToPeer_Title"
    case successConnectToast = "PeerToPeer_SuccessConnect_Toast"
    case serverErrorToast = "PeerToPeer_ServerError_Toast"
    
    case connectionFailedTitle = "PeerToPeer_ConnectionFailed_SheetTitle"
    case connectionFailedExpl = "PeerToPeer_ConnectionFailed_SheetExpl"
    case connectionFailedAction = "PeerToPeer_ConnectionFailed_SheetAction"

    case verificationSubhead = "PeerToPeer_Verification_Subhead"
    
    case verificationSenderPart1 = "PeerToPeer_Verification_Sender_Part1_Expl"
    case verificationSenderPart2 = "PeerToPeer_Verification_Sender_Part2_Expl"
    case verificationReceipientPart1 = "PeerToPeer_Verification_Receipient_Part1_Expl"
    case verificationReceipientPart2 = "PeerToPeer_Verification_Receipient_Part2_Expl"

    case verificationConfirm = "PeerToPeer_Verification_Action_Confirm"
    case verificationDiscard = "PeerToPeer_Verification_Action_Discard"
}
