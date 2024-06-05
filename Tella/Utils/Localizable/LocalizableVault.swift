//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

enum LocalizableVault: String, LocalizableDelegate {
    
    // Edit Image
    case editFileConfirmExitTitle = "Vault_EditImage_Exit_SheetTitle"
    case editFileConfirmExitExpl = "Vault_EditImage_Exit_SheetExpl"
    case editFileExitSheetAction = "Vault_EditImage_Exit_SheetAction"
    case editFileSavedToast = "Vault_EditImage_ImageSaved_Toast";
    
    // Sort By
    
    case rootDirectoryName = "Vault_RootDirectoryName"
    
    case SortBySheetTitle = "Vault_SortBy_SheetTitle"
    case sortByName = "Vault_SortBy_Name"
    case sortByDate = "Vault_SortBy_Date"
    case sortByAscendingNameSheetSelect = "Vault_SortBy_AscendingName_SheetSelect"
    case sortByDescendingNameSheetSelect = "Vault_SortBy_DescendingName_SheetSelect"
    case sortByAscendingDateSheetSelect = "Vault_SortBy_AscendingDate_SheetSelect"
    case sortByDescendingDateSheetSelect = "Vault_SortBy_DescendingDate_SheetSelect"
    
    case itemsAppBar = "Vault_Items_AppBar"
    case itemAppBar = "Vault_Item_AppBar"
    
    // Manage Files
    
    case manageFilesSheetTitle = "Vault_ManageFiles_SheetTitle"
    case manageFilesTakePhotoVideoSheetSelect = "Vault_ManageFiles_TakePhotoVideo_SheetSelect"
    case manageFilesRecordAudioSheetSelect = "Vault_ManageFiles_RecordAudio_SheetSelect"
    case manageFilesImportFromDeviceSheetSelect = "Vault_ManageFiles_ImportFromDevice_SheetSelect"
    case manageFilesCreateNewFolderSheetSelect = "Vault_ManageFiles_CreateNewFolder_SheetSelect"
    case manageFilesPhotoLibrarySheetSelect = "Vault_ManageFiles_PhotoLibrary_SheetSelect"
    case manageFilesDocumentSheetSelect = "Vault_ManageFiles_Document_SheetSelect"
    
    
    // File actions
    
    case moreActionsShareSheetSelect = "Vault_MoreActions_Share_SheetSelect"
    case moreActionsMoveSheetSelect = "Vault_MoreActions_Move_SheetSelect"
    case moreActionsRenameSheetSelect = "Vault_MoreActions_Rename_SheetSelect"
    case moreActionsEditSheetSelect = "Vault_MoreActions_Edit_SheetSelect"
    case moreActionsSaveSheetSelect = "Vault_MoreActions_Save_SheetSelect"
    case moreActionsFileInformationSheetSelect = "Vault_MoreActions_FileInformation_SheetSelect"
    case moreActionsDeleteSheetSelect = "Vault_MoreActions_Delete_SheetSelect"
    
    case renameFileSheetTitle = "Vault_RenameFile_SheetTitle"
    case renameFileCancelSheetAction = "Vault_RenameFile_Cancel_SheetAction"
    case renameFileSaveSheetAction = "Vault_RenameFile_Save_SheetAction"
    case deleteFileWarningDescription = "Vault_DeleteFile_Warning_SheetDescription"
    case deleteFileWarningTitle = "Vault_DeleteFile_Warning_SheetTitle"
    case deleteFileDeleteAnyway = "Vault_DeleteFile_DeleteAnyway_SheetAction"
    
    case createNewFolderSheetTitle = "Vault_CreateNewFolder_SheetTitle"
    case createNewFolderCancelSheetAction = "Vault_CreateNewFolder_Cancel_SheetAction"
    case createNewFolderCreateSheetAction = "Vault_CreateNewFolder_Create_SheetAction"
    
    case deleteFileSheetTitle = "Vault_DeleteFile_SheetTitle"
    case deleteFilesSheetTitle = "Vault_DeleteFiles_SheetTitle"
    case deleteFileSheetExpl = "Vault_DeleteFile_SheetExpl"
    case deleteFilesSheetExpl = "Vault_DeleteFiles_SheetExpl"
    case deleteFolderSheetTitle = "Vault_DeleteFolder_SheetTitle"
    case deleteFoldersSheetTitle = "Vault_DeleteFolders_SheetTitle"
    case deleteFolderSheetExpl = "Vault_DeleteFolder_SheetExpl"
    case deleteFoldersSheetExpl = "Vault_DeleteFolders_SheetExpl"
    case deleteFolderSingleFileSheetExpl = "Vault_DeleteFolderSingleFile_SheetExpl"
    case deleteFoldersSingleFileSheetExpl = "Vault_DeleteFoldersSingleFile_SheetExpl"
    case deleteFileCancelSheetAction = "Vault_DeleteFile_Cancel_SheetAction"
    case deleteFileDeleteSheetAction = "Vault_DeleteFile_Delete_SheetAction"
    
    
    case saveToDeviceSheetTitle = "Vault_SaveToDevice_SheetTitle"
    case saveToDeviceSheetExpl = "Vault_SaveToDevice_SheetExpl"
    case saveToDeviceSaveSheetAction = "Vault_SaveToDevice_Save_SheetAction"
    case saveToDeviceCancelSheetAction = "Vault_SaveToDevice_Cancel_SheetAction"
    
    case importDeleteTitle = "Vault_ImportDelete_Title"
    case importDeleteContent = "Vault_ImportDelete_Content"
    case importDeleteSubcontent = "Vault_ImportDelete_SubContent"
    case importDeleteKeepOriginal = "Vault_ImportDelete_KeepOriginal"
    case importDeleteDeleteOriginal = "Vault_ImportDelete_DeleteOriginal"
    
    // Move File
    case moveFileAppBar = "Vault_MoveFile_AppBar"
    case moveFileActionCancel = "Vault_MoveFile_Action_Cancel"
    case moveFileActionMove = "Vault_MoveFile_Action_Move"
    
    // File Info
    case verifInfoAppBar = "Vault_VerifInfo_AppBar"
    case verifInfoFileName = "Vault_VerifInfo_FileName"
    case verifInfoSize = "Vault_VerifInfo_Size"
    case verifInfoFormat = "Vault_VerifInfo_Format"
    case verifInfoCreated = "Vault_VerifInfo_Created"
    case verifInfoResolution = "Vault_VerifInfo_Resolution"
    case verifInfoLength = "Vault_VerifInfo_Length"
    case verifInfoFilePath = "Vault_VerifInfo_FilePath"
    
    // Import Progress
    case importProgressSheetTitle = "Vault_ImportProgress_SheetTitle"
    case importProgressSheetExpl = "Vault_ImportProgress_SheetExpl"
    case importProgressCancelSheetAction = "Vault_ImportProgress_Cancel_SheetAction"
    
    
    // Cancel Import File
    case cancelImportFileSheetTitle = "Vault_CancelImportFile_SheetTitle"
    case cancelImportFileSheetExpl = "Vault_CancelImportFile_SheetExpl"
    case cancelImportFileBackSheetAction = "Vault_CancelImportFile_Back_SheetAction"
    case cancelImportFileCancelImportSheetAction = "Vault_CancelImportFile_CancelImport_SheetAction"
    
    // Empty File Message
    
    case emptyAllFilesExpl = "Vault_EmptyAllFiles_Expl"
    case emptyFolderExpl = "Vault_EmptyFolder_Expl"
    
    case fileAudioUpdateSecondTime = "Vault_FileAudio_UpdateSecondTime"
}
