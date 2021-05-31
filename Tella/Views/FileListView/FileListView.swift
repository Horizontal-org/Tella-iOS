//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = .clear
    }
    
    var body: some View {
        List{
            FileGridItem()
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
        FileListView()
//        VStack{
//            FileListItem()
//            FileGridItem()
//        }.frame(width: 500, height: 100, alignment: .leading)
    }
}
