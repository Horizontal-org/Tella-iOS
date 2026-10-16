//
//  Locked.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/10/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation

/// Keeps a value and its lock together, providing synchronized reads and mutations.
final class Locked<Value> {
    private let lock = NSLock()
    private var value: Value

    init(_ value: Value) {
        self.value = value
    }

    func withValue<Result>(_ block: (inout Value) -> Result) -> Result {
        lock.withLock { block(&value) }
    }
}
