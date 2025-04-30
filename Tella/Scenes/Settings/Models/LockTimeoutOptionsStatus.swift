//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


class LockTimeoutOptionsStatus :Hashable, ObservableObject{
    
    @Published var lockTimeoutOption :  LockTimeoutOption
    @Published var isSelected :  Bool
    
    init(lockTimeoutOption :  LockTimeoutOption, isSelected :  Bool) {
        self.lockTimeoutOption = lockTimeoutOption
        self.isSelected = isSelected
    }
    
    static func == (lhs: LockTimeoutOptionsStatus, rhs: LockTimeoutOptionsStatus) -> Bool {
        lhs.lockTimeoutOption  == rhs.lockTimeoutOption
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(lockTimeoutOption.hashValue)
    }
    
}
