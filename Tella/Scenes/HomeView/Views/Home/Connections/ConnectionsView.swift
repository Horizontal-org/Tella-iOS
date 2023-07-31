//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI


struct ConnectionsView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        if homeViewModel.serverDataItemArray.count > 0 {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connections")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                
                serversView
            }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
        }
    }
    
    var serversView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            serverItems
        }
    }
    
    @ViewBuilder
    var serverItems : some View {
        HStack(spacing: 7) {
            
            ForEach(homeViewModel.serverDataItemArray, id: \.self) { server in
                switch server.serverType {
                    
                case .tella:
                    ConnectionsItemView(title: LocalizableReport.reportsTitle.localized,
                                        image: "home.report",
                                        destination: ReportsView(mainAppModel: appModel))
                case .uwazi:
                    ConnectionsItemView(title: "Uwazi",
                                        image: "home.uwazi",
                                        destination: UwaziView(mainAppModel: appModel))
                default:
                    ConnectionsItemView(title: LocalizableReport.reportsTitle.localized,
                                        image: "home.report",
                                        destination: ReportsView(mainAppModel: appModel))
                }
                
            }
            
            Spacer()
        }.padding(.trailing, 17)
        
    }
}

struct ConnectionsItemView<Destination:View>: View {
    var title : String
    var image : String
    var destination : Destination
    
    var body: some View {
        Button {
            navigateTo(destination: destination, title: title, largeTitle: true)
        } label: {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.2))
                .frame(width: 92,height: 92)
                .overlay(
                    VStack {
                        Image(image)
                        Text(title)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                            .foregroundColor(.white)
                    }
                )
        }
    }
}

struct ConnectionsView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionsView()
    }
}
