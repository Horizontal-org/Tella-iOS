//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class ProgressFileItemViewModel: ObservableObject {
    
    let vaultFile: VaultFileDB
    
    @Published var transferSummary: String
    @Published var transferProgress: Double?

    init(vaultFile: VaultFileDB, transferSummary: String, transferProgress: Double? = nil) {
        self.vaultFile = vaultFile
        self.transferSummary = transferSummary
        self.transferProgress = transferProgress
    }
}
