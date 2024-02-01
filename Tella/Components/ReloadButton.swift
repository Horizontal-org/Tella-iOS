//
//  ReloadButton.swift
//  Tella
//
//  Created by gus valbuena on 1/31/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ReloadButton: View {
    var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image("arrow.clockwise")
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}

extension View {
    func reloadButton(action: @escaping () -> Void) -> ToolbarItem<(), ReloadButton> {
        ToolbarItem(placement: .navigationBarTrailing) {
            ReloadButton(action: action)
        }
    }
}

#Preview {
    ReloadButton(action: {})
}
