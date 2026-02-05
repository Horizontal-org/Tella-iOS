//
//  LocalizableNearbySharing.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/1/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



enum LocalizableNearbySharing: String, LocalizableDelegate {

    case nearbySharingMainAppBar = "NearbySharing_Main_AppBar"
    case nearbySharing = "NearbySharing"
    case nearbySharingSubhead = "NearbySharing_Main_Subhead"
    case nearbySharingExpl = "NearbySharing_Main_Expl"
    case sendFiles = "NearbySharing_Main_SendFiles"
    case receiveFiles = "NearbySharing_Main_ReceiveFiles"
    
    case learnMore = "NearbySharing_Main_LearnMore"

    case sameNetworkSheetTitle = "NearbySharing_SameNetwork_SheetTitle"
    case sameNetworkSheetExpl = "NearbySharing_SameNetwork_SheetExpl"
    case sameNetworkYesAction = "NearbySharing_SameNetwork_Yes_SheetAction"
    case sameNetworkNoAction = "NearbySharing_SameNetwork_No_SheetAction"

    case dontShowAgain = "NearbySharing_SameNetwork_DontShowAgain"

    
    case helpAppBar = "NearbySharing_Help_AppBar"

    
    
    case helpConnectDeviceTitle = "NearbySharing_Help_ConnectDevice_Title"
    case helpConnectDevicePart1 = "NearbySharing_Help_ConnectDevice_Part1"
    case helpConnectDevicePart2 = "NearbySharing_Help_ConnectDevice_Part2"
    case helpConnectDevicePart3 = "NearbySharing_Help_ConnectDevice_Part3"

    case helpNeedInternetTitle = "NearbySharing_Help_NeedInternet_Title"
    case helpNeedInternetExpl = "NearbySharing_Help_NeedInternet_Expl"

    case moreTips = "NearbySharing_Help_MoreTips"
    case helpMoreTipsPart1 = "NearbySharing_Help_MoreTips_Part1"
    case helpMoreTipsPart2 = "NearbySharing_Help_MoreTips_Part2"
    case helpMoreTipsPart3 = "NearbySharing_Help_MoreTips_Part3"
    case helpMoreTipsDocumentation = "NearbySharing_Help_MoreTips_documentation"
    
    case connectToDevice = "NearbySharing_ConnectToDevice"
    case scanCode = "NearbySharing_ScanCode"
    case showQrCode = "NearbySharing_ShowQrCode"
    case havingTrouble = "NearbySharing_HavingTrouble"
    case connectManually = "NearbySharing_ConnectManually"
    case enterDeviceInformation = "NearbySharing_EnterDevice_Information"
    case ipAddress = "NearbySharing_IpAddress"
    case pin = "NearbySharing_Pin"
    case port = "NearbySharing_Port"
    case publicKey = "NearbySharing_PublicKey"
    case showDeviceInformation = "NearbySharing_ShowDeviceInformation"
    case sendInputDesc = "NearbySharing_ConnectToDevice_SenderInputDesc"
    case locationAccess = "NearbySharing_LocationAccess"
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

    case verificationAppBar = "NearbySharing_Verification_AppBar"

    case verificationSender = "NearbySharing_Verification_Sender_Expl"

    case verificationRecipient = "NearbySharing_Verification_Recipient_Expl"
 
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
