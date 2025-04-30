//
//  PinKeyboardModel.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct PinKeyboardModel: Hashable {
    var text: String = ""
    var imageName: String = ""
    var type: PinType = .empty
    
    init(type: PinType) {
        self.type = type
    }
    
    init(text: String, type: PinType) {
        self.text = text
        self.type = type
    }
    
    init(imageName: String, type: PinType) {
        self.imageName = imageName
        self.type = type
    }
}

enum PinType {
    case number
    case done
    case delete
    case empty
}
