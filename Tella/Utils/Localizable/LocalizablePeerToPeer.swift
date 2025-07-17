//
//  LocalizablePeerToPeer.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    case verificationRecipientPart1 = "PeerToPeer_Verification_Recipient_Part1_Expl"
    case verificationRecipientPart2 = "PeerToPeer_Verification_Recipient_Part2_Expl"

    case verificationConfirm = "PeerToPeer_Verification_Action_Confirm"
    case verificationWaitingSender = "PeerToPeer_Verification_Action_WaitingSender"
    case verificationWaitingRecipient = "PeerToPeer_Verification_Action_WaitingRecipient"

    case verificationDiscard = "PeerToPeer_Verification_Action_Discard"
    
    case senderFilesRejected = "PeerToPeer_Sender_FilesRejected_Toast"
    
    case recipientFilesRejected = "PeerToPeer_Recipient_FilesRejected_Toast"
    case senderWaitingRecipient = "PeerToPeer_Sender_WaitingRecipient_Toast"

    
    case stopSharingTitle = "PeerToPeer_StopSharing_SheetTitle"
    case stopSharingSheetExpl = "PeerToPeer_StopSharing_SheetExpl"
    case continueSharing = "PeerToPeer_StopSharing_Continue_SheetAction"
    case stopSharing = "PeerToPeer_StopSharing_Stop_SheetAction"

    case senderPercentageSent = "PeerToPeer_Sender_PercentageSent"
    case senderFilesSent = "PeerToPeer_Sender_FilesSent"
    case senderFileSent = "PeerToPeer_Sender_FileSent"
    
    case recipientPercentageReceived = "PeerToPeer_Recipient_PercentageReceived"
    case recipientFilesReceived = "PeerToPeer_Recipient_FilesReceived"
    case recipientFileReceived = "PeerToPeer_Recipient_FileReceived"

    case receivingAppBar = "PeerToPeer_Recipient_Receiving_AppBar"
    case stopReceivingSheetTitle = "PeerToPeer_StopReceiving_SheetTitle"
    case stopReceivingSheetExpl = "PeerToPeer_StopReceiving_SheetExpl"
    
    case senderSendingAppBar = "PeerToPeer_Sender_Sending_AppBar"

    case resultsAppBar = "PeerToPeer_Results_AppBar"
    case successTitle = "PeerToPeer_Results_Success_Title"
    
    case successFilesReceivedExpl = "PeerToPeer_Results_SuccessFilesReceived_Expl"
    case successFileReceivedExpl = "PeerToPeer_Results_SuccessFileReceived_Expl"

    case successFilesSentExpl = "PeerToPeer_Results_SuccessFilesSent_Expl"
    case successFileSentExpl = "PeerToPeer_Results_SuccessFileSent_Expl"

    case failureTitle = "PeerToPeer_Results_Failure_Title"
    
    case filesReceivedFilesNotReceivedExpl = "PeerToPeer_Results_FilesReceived_FilesNotReceived_Expl"
    case fileReceivedFilesNotReceivedExpl = "PeerToPeer_Results_FileReceived_FilesNotReceived_Expl"
    case filesReceivedFileNotReceivedExpl = "PeerToPeer_Results_FilesReceived_FileNotReceived_Expl"
    case fileReceivedFileNotReceivedExpl = "PeerToPeer_Results_FileReceived_FileNotReceived_Expl"

    case failureFilesReceivedExpl = "PeerToPeer_Results_FailureFilesReceived_Expl"
    case failureFileReceivedExpl = "PeerToPeer_Results_FailureFileReceived_Expl"

    case viewFilesAction = "PeerToPeer_Results_ViewFiles_Action"
}
