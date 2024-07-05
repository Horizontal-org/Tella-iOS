//
//  DraftViewModelProtocol.swift
//  Tella
//
//  Created by gus valbuena on 6/24/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
protocol DraftViewModelProtocol: ObservableObject {
    //report
    var reportId: Int? { get set }
    var title: String { get set }
    var description: String { get set }
    var status: ReportStatus? { get set }
    
    
    //validation
    var isValidTitle: Bool { get set }
    var isValidDescription: Bool { get set }
    var shouldShowError: Bool { get set }
    var reportIsValid: Bool { get set }
    var reportIsDraft: Bool { get set}
    var successSavingReport: Bool { get set }
    var failureSavingReport: Bool { get set }
    var successSavingReportPublisher: Published<Bool>.Publisher { get }
    var failureSavingReportPublisher: Published<Bool>.Publisher { get }
    
    //files
    var files: Set<VaultFileDB> { get set }
    var resultFile: [VaultFileDB]? { get set }
    var addFileToDraftItems: [ListActionSheetItem] { get }
    var showingImagePicker: Bool { get set }
    var showingImportDocumentPicker: Bool { get set }
    var showingFileList: Bool { get set }
    var showingRecordView: Bool { get set }
    var showingCamera: Bool { get set }
    
    //actions
    func submitReport()
    func saveDraftReport()
    func saveFinalizedReport()
    func deleteFile(fileId: String?)
}
