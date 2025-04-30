//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct AddNewFolderView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @ObservedObject var fileListViewModel : FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    @State var fieldContent : String = ""
    
    var body: some View {
        
        ZStack {
            VStack {
                AddFileYellowButton(action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                        showCreateNewFolderSheet()
                    })
                })
                
                Spacer()
                    .frame(height: 50)
            }
        }
    }
    
    func showCreateNewFolderSheet() {
        sheetManager.showBottomSheet( modalHeight: 165, backgroundColor: Styles.Colors.lightBlue, content: {
            TextFieldBottomSheetView(titleText: LocalizableVault.createNewFolderSheetTitle.localized,
                                     validateButtonText: LocalizableVault.createNewFolderCreateSheetAction.localized,
                                     cancelButtonText: LocalizableVault.createNewFolderCancelSheetAction.localized,
                                     fieldContent: $fieldContent,
                                     didConfirmAction:  {
                fileListViewModel.addFolder(name: fieldContent)
            })
            
        })
    }
}

struct AddNewFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewFolderView(fileListViewModel: FileListViewModel.stub())
            .background(Styles.Colors.backgroundMain)
    }
}
