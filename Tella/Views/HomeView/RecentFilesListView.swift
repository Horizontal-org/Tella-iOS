//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFilesListView: View {

    @ObservedObject var viewModel: HomeViewModel
    @State var recentFilesCount: Int
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.recentFilesCount = viewModel.fileManager.recentFiles.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("Recent files")
                .font(Font(UIFont.boldSystemFont(ofSize: 14)))
                .foregroundColor(.white)
                .frame(maxHeight: 24, alignment: .leading)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            if recentFilesCount > 0 {
                recentFilesView
            } else {
                emptyRecentFilesView
            }
        }
        .frame(height: recentFilesCount > 0 ? 180: 100)
        .background(Color(Styles.Colors.backgroundMain))
    }
    
    var recentFilesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
              
              ForEach(viewModel.fileManager.recentFiles, id: \.fileName) { file in
                  Divider()
                    NavigationLink(destination: FileDetailView(file: file)) {
                      RecentFileCell(recentFile: file)
                  }
              }.listRowBackground(Color.red)

          }
        }
        .frame(height: 70)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
    }
    
    var emptyRecentFilesView: some View {
        Text("No Recent Files")
            .foregroundColor(Color.white)
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentFilesListView(viewModel: HomeViewModel())
    }
}
