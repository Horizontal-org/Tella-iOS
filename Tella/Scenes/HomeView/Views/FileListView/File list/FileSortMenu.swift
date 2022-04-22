//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileSortMenu: View {
    
    @EnvironmentObject var fileListViewModel : FileListViewModel
    
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
        ZStack{
            
            DragView(modalHeight: 300,
                     isShown: $fileListViewModel.showingSortFilesActionSheet){
                ActionListBottomSheet(items: items, headerTitle: Localizable.Home.sortByTitle,
                                      isPresented: $fileListViewModel.showingSortFilesActionSheet,
                                      action:  {item in
                    self.handleActions(item : item)
                })
            }
        }
    }
    
    private func handleActions(item: ListActionSheetItem) {
        fileListViewModel.showingSortFilesActionSheet = false
        guard let type = item.type as? FileSortOptions else { return }
        fileListViewModel.sortBy = type
    }
}

struct FileSortSheet_Previews: PreviewProvider {
    static var previews: some View {
        FileSortMenu()
            .environmentObject(MainAppModel())
            .environmentObject(FileListViewModel.stub())
    }
}
