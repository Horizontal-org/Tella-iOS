//
//  ViewModelState.swift
//  Tella
//
//  Created by gus valbuena on 6/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum ViewModelState<T: Equatable>: Equatable {
    case loading
    case loaded(T)
    case error(String)
    
    static func == (lhs: ViewModelState<T>, rhs: ViewModelState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
