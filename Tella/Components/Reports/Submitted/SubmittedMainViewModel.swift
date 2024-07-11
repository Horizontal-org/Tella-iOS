//
//  SubmittedMainViewModel.swift
//  Tella
//
//  Created by gus valbuena on 7/11/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class SubmittedMainViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    // Report
    @Published var id : Int?
    @Published var title : String = ""
    @Published var description : String = ""
    @Published var files :  [VaultFileDB] = []
    
    @Published var progressFileItems : [ProgressFileItemViewModel] = []
    @Published var uploadedDate : String = ""
    @Published var uploadedFiles : String = ""
    
    var reportHasFile: Bool {
        return !files.isEmpty
    }
    
    var reportHasDescription: Bool {
        return !description.isEmpty
    }
    
    init(mainAppModel: MainAppModel, shouldStartUpload: Bool = false, reportId: Int?) {
        self.mainAppModel = mainAppModel
        fillReportVM(reportId: reportId)
    }
    
    func fillReportVM(reportId:Int?) {}
    
    func deleteReport() {}
}
