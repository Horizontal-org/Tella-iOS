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

    init(file: VaultFileDB, progression: String, fileStatus: FileStatus? = nil) {
        self.file = file
        self.progression = progression
        self.fileStatus = fileStatus
    }
}
