//
//  ResultExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/10/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public extension Result where Success == Void {
    
    /// A success, storing a Success value.
    ///
    /// Instead of `.success(())`, now  `.success`
    static var success: Result {
        return .success(())
    }
}
