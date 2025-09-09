//
//  SSIDViewModel.swift
//  Tella
//
//  Created by RIMA on 03.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

class GetConnectedViewModel: NSObject, ObservableObject {
    
    var participant: NearbySharingParticipant
    private var mainAppModel:MainAppModel
    
    init(participant: NearbySharingParticipant, mainAppModel:MainAppModel) {
        self.participant = participant
        self.mainAppModel = mainAppModel
    }
}
