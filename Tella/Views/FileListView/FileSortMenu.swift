//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileSortMenu: View {
    
    @Binding var showingSortFilesActionSheet: Bool
    @Binding var sortBy: FileSortOptions

    var body: some View {
        HStack{
        }
        .actionSheet(isPresented: $showingSortFilesActionSheet, content: {
            sortFilesActionSheet
        })

    }
    
    var sortFilesActionSheet: ActionSheet {
        ActionSheet(title: Text("Sort by"),  buttons: [
            .default(Text("Name A > Z")) {
                sortBy = .nameAZ
            },
            .default(Text("Name Z > A")) {
                sortBy = .nameZA
            },
            .default(Text("Newest to oldest")) {
                sortBy = .newestToOldest
            },
            .default(Text("Oldest to newest")) {
                sortBy = .oldestToNewest
            },
            .cancel()
        ])
    }
    
}
