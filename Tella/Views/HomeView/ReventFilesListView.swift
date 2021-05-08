//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReventFilesListView: View {

    var files: [RecentFileProtocol] = [RecentFileProtocol](repeating: mockRecentFile(), count: 10)
    
    init() {
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            Text("Recent files")
                .font(Font(UIFont.boldSystemFont(ofSize: 14)))
                .foregroundColor(.white)
                .frame(height: 24)
                .frame(maxHeight: 24, alignment: .leading)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 10) {
                ForEach(0..<files.count) { index in
                    Divider()
                    NavigationLink(
                                        destination: FileDetailView()
                                    ) {
                        RecentFileCell(file: files[index])
                    }
                }
              }
            }
            .frame(height: 70)
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        }
        .frame(height: 180)
        .background(Color(Styles.Colors.backgroundMain))
    }
}

struct ReventFilesListView_Previews: PreviewProvider {
    static var previews: some View {
        ReventFilesListView()
    }
}
