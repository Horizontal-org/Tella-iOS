//
//  DeleteFileView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DeleteFileView: View {
    
    @Binding var showingDeleteConfirmationSheet : Bool
    var didConfirmAction : (() -> Void)
    
    var body: some View {
        ConfirmBottomSheet(titleText: "Delete file?",
                           msgText: "The selected files will be permanently delated from Tella.",
                           cancelText: "CANCEL",
                           actionText: "DELETE",
                           destructive: true,
                           modalHeight: 161,
                           isPresented: $showingDeleteConfirmationSheet,
                           didConfirmAction: didConfirmAction)
    }
}

struct DeleteFileView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteFileView(showingDeleteConfirmationSheet: .constant(true),
                       didConfirmAction: {
            
        })
    }
}
