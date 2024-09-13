//
//  DropboxDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 9/12/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class DropboxDraftViewModel: DraftMainViewModel {
    private let dropboxRepository: DropboxRepositoryProtocol
    
    init(mainAppModel: MainAppModel, DropboxRepository: DropboxRepositoryProtocol, reportId: Int?) {
        self.dropboxRepository = DropboxRepository
        super.init(mainAppModel: mainAppModel, reportId: reportId)
    }
    
    override func validateReport() {
        Publishers.CombineLatest($title, $description)
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .assign(to: \.reportIsValid, on: self)
            .store(in: &subscribers)
                
        $title
            .map { !$0.isEmpty }
            .assign(to: \.reportIsDraft, on: self)
            .store(in: &subscribers)
    }
    
    override func saveReport() {
        dump(title)
        dump(description)
        Task {
           await sendReport()
        }
    }
    
    func sendReport() async {
        do {
            try await dropboxRepository.uploadReport(title: title, description: description, files: [])
        } catch let error {
            debugLog(error)
        }
    }
}
