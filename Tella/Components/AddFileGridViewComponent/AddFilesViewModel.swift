//
//  AddFilesViewModel.swift
//  Tella
//
//  Created by RIMA on 26.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class AddFilesViewModel: ObservableObject {
    
    @Published var files:  Set <VaultFileDB> = []
    @Published var showingImagePicker : Bool = false
    @Published var showingImportDocumentPicker : Bool = false
    @Published var showingFileList : Bool = false
    @Published var showingRecordView : Bool = false
    @Published var showingCamera : Bool = false
    @Published var resultFile : [VaultFileDB]?
    
    var mainAppModel: MainAppModel
    var subscribers = Set<AnyCancellable>()
    
    init( mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        bindVaultFileTaken()
    }
    
    var addFileBottomSheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "camera-filled.icon",
                            content: LocalizableReport.cameraFilled.localized,
                            type: ManageFileType.camera),
        ListActionSheetItem(imageName: "mic-filled.icon",
                            content: LocalizableReport.micFilled.localized,
                            type: ManageFileType.recorder),
        ListActionSheetItem(imageName: "gallery.icon",
                            content: LocalizableReport.galleryFilled.localized,
                            type: ManageFileType.tellaFile),
        ListActionSheetItem(imageName: "phone.icon",
                            content: LocalizableReport.phoneFilled.localized,
                            type: ManageFileType.fromDevice)
    ]}
    
    func bindVaultFileTaken() {
        $resultFile.sink(receiveValue: { value in
            guard let value else { return }
            self.files.insert(value)
        }).store(in: &subscribers)
    }
    
    func deleteFile(fileId: String?) {
        guard let index = files.firstIndex(where: { $0.id == fileId})  else  {return }
        files.remove(at: index)
    }
}

