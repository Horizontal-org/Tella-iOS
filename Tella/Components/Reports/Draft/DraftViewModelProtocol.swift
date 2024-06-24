//
//  DraftViewModelProtocol.swift
//  Tella
//
//  Created by gus valbuena on 6/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

protocol DraftViewModelProtocol: ObservableObject {
    var files: Set<VaultFileDB> { get set }
    var resultFile: [VaultFileDB]? { get set }
    var addFileToDraftItems: [ListActionSheetItem] { get }
    var showingImagePicker: Bool { get set }
    var showingImportDocumentPicker: Bool { get set }
    var showingFileList: Bool { get set }
    var showingRecordView: Bool { get set }
    var showingCamera: Bool { get set }
}
