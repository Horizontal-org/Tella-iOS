//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileSortMenu: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var fileSortOptions : [FileSortOptions] = [.nameAZ, .nameZA, .newestToOldest, .oldestToNewest]
    
    var items : [ListActionSheetItem] {
        
        var items : [ListActionSheetItem] = []
        fileSortOptions.forEach { item in
            items.append(ListActionSheetItem(imageName: fileListViewModel.sortBy == item ? "radio_selected" : "radio_unselected",
                                             content: item.name,
                                             type: item))
        }
        return items
    }
    
    var body: some View {
        Button {
            showSortFilesActionSheet()
        } label: {
            HStack{
                Text(fileListViewModel.sortBy.displayName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14) )
                    .foregroundColor(.white)
                fileListViewModel.sortBy.image
                    .frame(width: 20, height: 20)
            }
        }
        .frame(height: 44)
    }
    
    private func handleActions(item: ListActionSheetItem) {
        sheetManager.hide()
        guard let type = item.type as? FileSortOptions else { return }
        fileListViewModel.sortBy = type
    }
    
    private func showSortFilesActionSheet() {
        sheetManager.showBottomSheet( modalHeight: 300, content: {
            ActionListBottomSheet(items: items, headerTitle: Localizable.Home.sortByTitle,
                                  action:  {item in
                self.handleActions(item : item)
            })
            
        }) 
    }
}

struct FileSortSheet_Previews: PreviewProvider {
    static var previews: some View {
        FileSortMenu()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
