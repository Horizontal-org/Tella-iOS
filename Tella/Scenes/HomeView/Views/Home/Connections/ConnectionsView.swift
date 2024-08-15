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
                                        destination: reportsMainView)
                    ConnectionsItemView(title: LocalizableResources.resourcesServerTitle.localized,
                                        image: "home.resources",
                                        destination: ResourcesView(mainAppModel: appModel),
                                        largeTitle: false,
                                        showTitle: false
                    )
                case .uwazi:
                    ConnectionsItemView(title: LocalizableHome.uwaziServerTitle.localized,
                                        image: "home.uwazi",
                                        destination: UwaziView().environmentObject(UwaziViewModel(mainAppModel: appModel, server: server.servers.first)))
                case .gDrive:
                    ConnectionsItemView(title: LocalizableGDrive.gDriveAppBar.localized,
                                        image: "home.drive",
                                        destination: gDriveMainView)
                case .nextcloud:
                    
                    ConnectionsItemView(title: LocalizableNextcloud.nextcloudAppBar.localized,
                                        image: "home.nextcloud",
                                        destination:nextcloudMainView)
                }
            }
            Spacer()
        }.padding(.trailing, 17)
    }
    
    var reportsMainView: some View {
        ReportMainView(reportMainViewModel: ReportsViewModel(mainAppModel: appModel), diContainer: GDriveDIContainer())
    }
    
    var gDriveMainView : some View {
        ReportMainView(reportMainViewModel: GDriveViewModel(mainAppModel: appModel),
                       diContainer: GDriveDIContainer())
    }
    
    var nextcloudMainView : some View {
        ReportMainView(reportMainViewModel: NextcloudReportViewModel(mainAppModel: appModel,
                                                                   connectionType: .nextcloud,
                                                                   title: LocalizableNextcloud.nextcloudAppBar.localized),
                       diContainer: GDriveDIContainer())
    }
}

struct ConnectionsItemView<Destination:View>: View {
    var title : String
    var image : String
    var destination : Destination
    var largeTitle : Bool = true
    var showTitle : Bool = true
    
    var body: some View {
        Button {
            navigateTo(
                destination: destination,
                title: showTitle ? title : nil,
                largeTitle: largeTitle)
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
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 80)
                            .lineLimit(2)
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
