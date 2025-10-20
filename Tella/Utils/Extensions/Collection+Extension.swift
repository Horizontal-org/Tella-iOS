//
//  Collection+Extension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

// Safe subscript to avoid out-of-bounds if index desyncs briefly
extension Collection {
    subscript(safe i: Index) -> Element? {
        indices.contains(i) ? self[i] : nil
    }
}
