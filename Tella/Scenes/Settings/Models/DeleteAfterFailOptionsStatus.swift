//
//  DeleteAfterFailOptionsStatus.swift
//  Tella
//
//  Created by Gustavo on 10/07/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class DeleteAfterFailedOptionsStatus :Hashable, ObservableObject {
    @Published var deleteAfterFailOption: DeleteAfterFailOption
    @Published var isSelected: Bool
    
    init(deleteAfterFailOption: DeleteAfterFailOption, isSelected: Bool){
        self.deleteAfterFailOption = deleteAfterFailOption
        self.isSelected = isSelected
    }
    
    static func == (lhs: DeleteAfterFailedOptionsStatus, rhs: DeleteAfterFailedOptionsStatus) -> Bool {
        lhs.deleteAfterFailOption  == rhs.deleteAfterFailOption
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(deleteAfterFailOption.hashValue)
    }
}
