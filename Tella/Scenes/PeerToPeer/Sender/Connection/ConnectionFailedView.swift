//
//  ConnectionFailedView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ConnectionFailedView: View {
    
    var tryAction: (()->())?
    
    var body: some View {
        ConfirmBottomSheet(titleText: LocalizablePeerToPeer.connectionFailedTitle.localized,
                           msgText: LocalizablePeerToPeer.connectionFailedExpl.localized,
                           actionText:LocalizablePeerToPeer.connectionFailedAction.localized,
                           shouldHideSheet: false,
                           didConfirmAction: {
            self.dismiss {
                tryAction?()
            }
        })
    }
}

#Preview {
    ConnectionFailedView(tryAction: {})
}
