//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddNewFolderView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
    @State var showingCreateNewFolderSheet : Bool = false
    @State var fieldContent : String = ""
    
    var body: some View {
        
        ZStack {
            VStack {
                AddFileYellowButton(action: {
                    showingCreateNewFolderSheet = true
                })
                
                Spacer()
                    .frame(height: 50)
            }
            
            TextFieldBottomSheetView(titleText: Localizable.Home.createNewFolder,
                                     validateButtonText: Localizable.Common.create,
                                 isPresented: $showingCreateNewFolderSheet,
                                 fieldContent: $fieldContent,
                                 fieldType: .text,
                                 backgroundColor:Styles.Colors.lightBlue,
                                 didConfirmAction:  {
                fileListViewModel.add(folder: fieldContent)
            })
        }
    }
}

struct CreateNewFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewFolderView()
    }
}
