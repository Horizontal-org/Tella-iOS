//
//  Transaction+Extension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 11/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

extension Transaction {
    
    static func withoutAnimation(_ updates: () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction, updates)
    }
}

func withoutAnimation(_ updates: () -> Void) {
    Transaction.withoutAnimation(updates)
}
