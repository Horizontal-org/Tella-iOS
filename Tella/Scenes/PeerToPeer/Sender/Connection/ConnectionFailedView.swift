//
//  ConnectionFailedView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 2/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
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
