//
//  NextBottomView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 16/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct NextBottomView: View {
    var title : String
    var nextAction : (() -> Void)?
    var isValid: Binding<Bool>
    
    init(title: String, isValid: Binding<Bool> = .constant(true), nextAction: (() -> Void)? = nil) {
        self.title = title
        self.isValid = isValid
        self.nextAction = nextAction
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            BottomButtonActionView(title: title, 
                                   isValid: isValid) {
                self.nextAction?()
            }
        }
    }
}

#Preview {
    NextBottomView(title: "Next", isValid: .constant(true))
}
