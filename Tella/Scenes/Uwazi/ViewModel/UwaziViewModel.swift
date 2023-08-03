//
//  UwaziViewModel.swift
//  Tella
//
//  Created by Gustavo on 31/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class UwaziReportsViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var templates : [UwaziTemplateRow] = []
    @Published var downloadedTemplates : [UwaziTemplateRow] = []
    @Published var draftReports : [Report] = []
    @Published var outboxedReports : [Report] = []
    @Published var submittedReports : [Report] = []
    @Published var selectedReport : Report?
    @Published var selectedCell = Pages.templates
    @Published var pageViewItems : [PageViewItem] = [
        PageViewItem(title: "Templates", page: .templates, number: ""),
        PageViewItem(title: LocalizableReport.draftTitle.localized, page: .draft, number: "") ,
        PageViewItem(title: LocalizableReport.outboxTitle.localized, page: .outbox, number: ""),
        PageViewItem(title: LocalizableReport.submittedTitle.localized, page: .submitted, number: "")
    ]
    
    @Published var isLoading: Bool = false
    @Published var serverURL : String = "https://"
    @Published var serverName : String
    
    var subscribers = Set<AnyCancellable>()
    
    
    var sheetItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "view-icon",
                            content: self.selectedReport?.status?.sheetItemTitle ?? "",
                            type: self.selectedReport?.status?.reportActionType ?? .viewSubmitted),
        ListActionSheetItem(imageName: "delete-icon-white",
                            content: LocalizableReport.viewModelDelete.localized,
                            type: ReportActionType.delete)
    ]}
    
    
    init(mainAppModel : MainAppModel, server: Server) {
        
        self.mainAppModel = mainAppModel
        dump(server)
        self.serverURL = server.url ?? ""
        self.serverName = server.name ?? ""
        self.getTemplates()
    }
    
    
    func getTemplates() -> Void {
        isLoading = true
        guard let baseUrl = serverURL.getBaseURL() else { return}
        UwaziServerRepository().getTemplates(serverURL: baseUrl)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                
                switch completion {
                case .finished:
                    print("Finished")
                case .failure( _):
                    self.isLoading = false
                }
            }, receiveValue: { wrapper in
                self.isLoading = false
                
                self.templates = wrapper.rows ?? []
                
                
            }).store(in: &subscribers)
    }
    
    func downloadTemplate(template: UwaziTemplateRow) -> Void {
        isLoading = true
        
        downloadedTemplates.append(template)
        
        isLoading = false
        
    }
    
}
