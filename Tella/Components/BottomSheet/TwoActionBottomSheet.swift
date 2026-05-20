//
//  TwoActionBottomSheet.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 20/5/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct TwoActionBottomSheet: View {
    
    let titleText: String
    let messageText: String
    let primaryButtonText: String
    let secondaryButtonText: String
    let didTapPrimaryAction: () -> Void
    let didTapSecondaryAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ConfirmBottomSheetHeaderView(titleText: titleText, msgText: messageText)
            Spacer()
            HStack {
                Spacer()
                BottomSheetButton(title: secondaryButtonText, action: didTapSecondaryAction)
                Spacer()
                    .frame(width: 10)
                BottomSheetButton(title: primaryButtonText, action: didTapPrimaryAction)
            }
        }
    }
}

#Preview {
    TwoActionBottomSheet(
        titleText: "Show project URL in settings?",
        messageText: "Message",
        primaryButtonText: "Show URL",
        secondaryButtonText: "Hide URL",
        didTapPrimaryAction: {},
        didTapSecondaryAction: {}
    )
    .padding()
    .background(Styles.Colors.backgroundTab)
}
