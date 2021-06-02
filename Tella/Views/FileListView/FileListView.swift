//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    var files: [VaultFile]
    
    init(files: [VaultFile]) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = .clear
        self.files = files
    }
    
    var body: some View {
        List{
            FileListItem()
            FileListItem()
            FileListItem()
        }
    }
}

struct FileListItem: View {
    
    var body: some View {
        
        HStack(spacing: 0){
            Image("test_image")
                .resizable()
                .frame(width: 35, height: 35)
                .background(Color.gray)
                .cornerRadius(5)
            VStack(alignment: .leading, spacing: 0){
                Text("Polling interview")
                    .font(Font(UIFont.boldSystemFont(ofSize: 14)))
                    .foregroundColor(Color.white)
                Text("18 may 2021")
                    .font(Font(UIFont.systemFont(ofSize: 10)))
                    .foregroundColor(Color(white: 0.8))
            }
            .padding(EdgeInsets(top: 0, leading: 27, bottom: 0, trailing: 16))
            Spacer()
            Image("test_image")
                .resizable()
                .frame(width: 35, height: 35)
                .background(Color.gray)
        }
        .listRowBackground(Color(Styles.Colors.backgroundMain))
        .frame(height: 45)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.yellow)
    }
}

struct FileGridItem: View {
    var body: some View {
        HStack() {
            Image("test_image")
                        .resizable()
                        .frame(width: 35, height: 35)
                    Text("landmark.name")
        }
    }
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        FileListView(files: VaultFile.stubFiles())
    }
}

extension VaultFile {
    
    static func stub(type: FileType) -> VaultFile {
        let file = VaultFile(type: type, fileName: UUID().uuidString, containerName: UUID().uuidString, files: nil)
        return file
    }

    static func stubFiles() -> [VaultFile] {
        return [VaultFile.stub(type: .audio),
                VaultFile.stub(type: .video),
                VaultFile.stub(type: .folder),
                VaultFile.stub(type: .document),
                VaultFile.stub(type: .document),
                VaultFile.stub(type: .image)]
    }
    
}
