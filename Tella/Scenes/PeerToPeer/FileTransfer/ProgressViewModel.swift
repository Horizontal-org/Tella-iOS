//
//  ProgressViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Combine
import Foundation

class ProgressViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var title: String
    @Published var description: String
    @Published var percentTransferredText : String
    @Published var transferredFilesSummary: String
    @Published var percentTransferred: Double
    @Published var progressFileItems: [ProgressFileItemViewModel]
    
    // MARK: - Initializer
    init(
        title: String = "",
        description: String = "",
        percentTransferredText: String = "",
        transferredFilesSummary: String = "",
        percentTransferred: Double = 0.0,
        progressFileItems: [ProgressFileItemViewModel] = []
    ) {
        self.title = title
        self.description = description
        self.percentTransferredText = percentTransferredText
        self.transferredFilesSummary = transferredFilesSummary
        self.percentTransferred = percentTransferred
        self.progressFileItems = progressFileItems
    }
}
