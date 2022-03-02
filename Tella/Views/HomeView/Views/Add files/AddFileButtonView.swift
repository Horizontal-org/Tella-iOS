//
//  AddFileButtonView.swift
//  Tella
//
// 
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileButtonView: View {
    
    @ObservedObject var appModel: MainAppModel
    var rootFile: VaultFile?
    
    @State var showingAddFileSheet = false
    @Binding var selectingFiles : Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            
            AddFileYellowButton(action: {
                showingAddFileSheet = true
                selectingFiles = false
            })
            
            AddFileBottomSheetFileActions(isPresented: $showingAddFileSheet,
                                          rootFile: rootFile)
        }
    }
}

struct AddFileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AddFileButtonView(appModel: MainAppModel(), selectingFiles: .constant(false))
    }
}
