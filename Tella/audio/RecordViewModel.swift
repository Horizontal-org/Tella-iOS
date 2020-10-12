//
//  RecordViewModel.swift
//  Tella
//
//  Created by Bruno Pastre on 12/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

enum RecordState {
    case ready
    case playing
    case paused
    case done
}

enum RecordEvent {
    case save
    case discard
    case start
    case cancel
    case pause
    case resume
    case complete
    
}

class RecordViewModel: ObservableObject {
    
}
