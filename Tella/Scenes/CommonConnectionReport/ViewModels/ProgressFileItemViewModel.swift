//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class ProgressFileItemViewModel: ObservableObject {
    var file : VaultFileDB
    @Published var progression : String
    @Published var fileStatus: FileStatus?
    @Published var p2pFileStatus: P2PFileStatus?
    init(file: VaultFileDB, progression: String, fileStatus: FileStatus? = nil) {
         p2pFileStatus: P2PFileStatus? = nil) {
        self.file = file
        self.progression = progression
        self.fileStatus = fileStatus
        self.p2pFileStatus = p2pFileStatus
    }
}

extension P2PFileStatus {
    var statusIcon: String? {
        switch self {
        case .transferring:
            return "home.progress-circle"
        case .finished:
            return "report.submitted"
        default:
            return nil
        }
    }
}
