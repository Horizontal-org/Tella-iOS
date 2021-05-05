//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileGroupsView: View {

    init() {
    }
    
    var body: some View {
        VStack(){
            Text("Files")
                .font(Font(UIFont.boldSystemFont(ofSize: 14)))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 24, alignment: .topLeading)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
            VStack() {
                HStack(){
                    Button(action: {}) {
                        FileGroupView(groupName: "My Files", iconName: "files.my_files")
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 4))
                    }
                    Button(action: {}) {
                        FileGroupView(groupName: "Gallery", iconName: "files.gallery")
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 8, trailing: 0))
                    }
                }
                HStack(){
                    Button(action: {}) {
                        FileGroupView(groupName: "Audio", iconName: "files.audio")
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
                    }
                    Button(action: {}) {
                    FileGroupView(groupName: "Documents", iconName: "files.documents")
                        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                    }
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                HStack(){
                    Button(action: {}) {
                        FileGroupView(groupName: "Others", iconName: "files.others")
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

        }
        .background(Color(Styles.Colors.backgroundMain))
    }
}

struct FileGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        FileGroupsView()
    }
}

struct FileGroupView: View {

    let groupName: String
    let iconName: String
    
    init(groupName: String, iconName: String) {
        self.groupName = groupName
        self.iconName = iconName
    }
        
    var body: some View {
        ZStack(alignment: .trailing){
            VStack(alignment: .trailing){
                Text(groupName)
                    .font(Font(UIFont.systemFont(ofSize: 14)))
                    .foregroundColor(.white)
                    .background(Color.clear)
                    .frame(maxWidth: .infinity, maxHeight: 80, alignment: .bottomLeading)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
            }
            VStack(alignment: .trailing){
                Image(iconName)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0))
            }
        }
        .frame(height: 80)
        .background(Color(Styles.Colors.backgroundFileButton))
        .cornerRadius(10)
    }
}
