//
//  LocalizableNearbySharing.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



enum LocalizableNearbySharing: String, LocalizableDelegate {

    case nearbySharingAppBar = "NearbySharing_AppBar"
    case nearbySharingSubhead = "NearbySharing_Main_Subhead"
    case nearbySharingExpl = "NearbySharing_Main_Expl"
    
    case sendFiles = "NearbySharing_Main_SendFiles"
    case receiveFiles = "NearbySharing_Main_ReceiveFiles"
    
    case learnMore = "NearbySharing_Main_LearnMore"
    case getConnected = "NearbySharing_Getconnected"
    case wifiConnectionDescription = "NearbySharing_WifiConnection_Desc"
    case wifiConnectionTipsToConnect = "NearbySharing_WifiConnection_TipsToConnect_Txt"
    case wifiConnectionTipsToConnectDescription = "NearbySharing_WifiConnection_TipsToConnect_Desc"
    case currentWifi = "NearbySharing_CurrentWifi"
    case wifiSameNetworkDescription = "NearbySharing_SameNetworkDescription"
    case connectToDevice = "NearbySharing_ConnectToDevice"
    case scanCode = "NearbySharing_ScanCode"
    case showQrCode = "NearbySharing_ShowQrCode"
    case havingTrouble = "NearbySharing_HavingTrouble"
    case wifi = "NearbySharing_Wifi"
    case connectManually = "NearbySharing_ConnectManually"
    case enterDeviceInformation = "NearbySharing_EnterDevice_Information"
    case ipAddress = "NearbySharing_IpAddress"
    case pin = "NearbySharing_Pin"
    case port = "NearbySharing_Port"
    case publicKey = "NearbySharing_PublicKey"
    case showDeviceInformation = "NearbySharing_ShowDeviceInformation"
    case sendInputDesc = "NearbySharing_ConnectToDevice_SenderInputDesc"
    case locationAccess = "NearbySharing_LocationAccess"
    case detectWifiSettingsDesc = "NearbySharing_WifiSettingsDesc"
    case cancel = "NearbySharing_Cancel"
    case settings = "NearbySharing_Settings"
    case noConnection = "NearbySharing_NoConnection"
    case waitingForSenderDesc = "NearbySharing_WaitingForSenderDesc"
    
    
    
    case senderRequestFilesNumberDesc = "NearbySharing_SenderRequest_NumberOfFiles_Desc"
    case requestQuestion = "NearbySharing_RequestQuestion"
    case accept = "NearbySharing_Accept"
    case reject = "NearbySharing_Reject"
    case invalidIpAddress = "NearbySharing_InvalidIpAddress"
    case invalidPin = "NearbySharing_InvalidPin"
    case selectFilesToSend = "NearbySharing_SelectFilesToSend"
    case title = "NearbySharing_Title"
    case successConnectToast = "NearbySharing_SuccessConnect_Toast"
    case serverErrorToast = "NearbySharing_ServerError_Toast"
    
    case connectionFailedTitle = "NearbySharing_ConnectionFailed_SheetTitle"
    case connectionFailedExpl = "NearbySharing_ConnectionFailed_SheetExpl"
    case connectionFailedAction = "NearbySharing_ConnectionFailed_SheetAction"

    
    case verificationSenderPart1 = "NearbySharing_Verification_Sender_Part1_Expl"
    case verificationSenderPart2 = "NearbySharing_Verification_Sender_Part2_Expl"
    case verificationRecipientPart1 = "NearbySharing_Verification_Recipient_Part1_Expl"
    case verificationRecipientPart2 = "NearbySharing_Verification_Recipient_Part2_Expl"

    case verificationConfirm = "NearbySharing_Verification_Action_Confirm"
    case verificationWaitingSender = "NearbySharing_Verification_Action_WaitingSender"
    case verificationWaitingRecipient = "NearbySharing_Verification_Action_WaitingRecipient"

    case verificationDiscard = "NearbySharing_Verification_Action_Discard"
    
    case senderFilesRejected = "NearbySharing_Sender_FilesRejected_Toast"
    
    case recipientFilesRejected = "NearbySharing_Recipient_FilesRejected_Toast"
    case senderWaitingRecipient = "NearbySharing_Sender_WaitingRecipient_Toast"

    
    case stopSharingTitle = "NearbySharing_StopSharing_SheetTitle"
    case stopSharingSheetExpl = "NearbySharing_StopSharing_SheetExpl"
    case continueSharing = "NearbySharing_StopSharing_Continue_SheetAction"
    case stopSharing = "NearbySharing_StopSharing_Stop_SheetAction"

    case senderPercentageSent = "NearbySharing_Sender_PercentageSent"
    case senderFilesSent = "NearbySharing_Sender_FilesSent"
    case senderFileSent = "NearbySharing_Sender_FileSent"
    
    case recipientPercentageReceived = "NearbySharing_Recipient_PercentageReceived"
    case recipientFilesReceived = "NearbySharing_Recipient_FilesReceived"
    case recipientFileReceived = "NearbySharing_Recipient_FileReceived"

    case receivingAppBar = "NearbySharing_Recipient_Receiving_AppBar"
    case stopReceivingSheetTitle = "NearbySharing_StopReceiving_SheetTitle"
    case stopReceivingSheetExpl = "NearbySharing_StopReceiving_SheetExpl"
    
    case senderSendingAppBar = "NearbySharing_Sender_Sending_AppBar"

    case resultsAppBar = "NearbySharing_Results_AppBar"
    case successTitle = "NearbySharing_Results_Success_Title"
    
    case successFilesReceivedExpl = "NearbySharing_Results_SuccessFilesReceived_Expl"
    case successFileReceivedExpl = "NearbySharing_Results_SuccessFileReceived_Expl"

    case successFilesSentExpl = "NearbySharing_Results_SuccessFilesSent_Expl"
    case successFileSentExpl = "NearbySharing_Results_SuccessFileSent_Expl"

    case failureTitle = "NearbySharing_Results_Failure_Title"
    
    case filesReceivedFilesNotReceivedExpl = "NearbySharing_Results_FilesReceived_FilesNotReceived_Expl"
    case fileReceivedFilesNotReceivedExpl = "NearbySharing_Results_FileReceived_FilesNotReceived_Expl"
    case filesReceivedFileNotReceivedExpl = "NearbySharing_Results_FilesReceived_FileNotReceived_Expl"
    case fileReceivedFileNotReceivedExpl = "NearbySharing_Results_FileReceived_FileNotReceived_Expl"

    case failureFilesReceivedExpl = "NearbySharing_Results_FailureFilesReceived_Expl"
    case failureFileReceivedExpl = "NearbySharing_Results_FailureFileReceived_Expl"

    case viewFilesAction = "NearbySharing_Results_ViewFiles_Action"
    
    case connectionChangedToast = "NearbySharing_ConnectionChanged_Toast"
}
