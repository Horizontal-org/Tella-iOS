//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI


struct ConnectionsView: View {
    
    @StateObject var homeViewModel: HomeViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text("Connections")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
            
            serversView
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
    }
    
    var serversView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            serverItems
        }
    }
    
    @ViewBuilder
    var serverItems : some View {
        HStack(spacing: 12) {
            
            if homeViewModel.mainAppModel.settings.nearbySharing {
                ConnectionsItemView(title: LocalizableNearbySharing.nearbySharing.localized,
                                    image: "nearby-sharing.home",
                                    destination: nearbySharingMainView)
            }
            
            ForEach(homeViewModel.serverDataItemArray, id: \.self) { server in
                switch server.serverType {
                    
                case .tella:
                    ConnectionsItemView(title: LocalizableReport.reportsTitle.localized,
                                        image: "home.report",
                                        destination: reportsMainView)
                    ConnectionsItemView(title: LocalizableResources.resourcesServerTitle.localized,
                                        image: "home.resources",
                                        destination: ResourcesView(mainAppModel: homeViewModel.mainAppModel),
                                        largeTitle: false,
                                        showTitle: false
                    )
                case .uwazi:
                    let uwaziViewModel = UwaziViewModel(mainAppModel: homeViewModel.mainAppModel, server: server.servers.first)
                    ConnectionsItemView(title: LocalizableHome.uwaziServerTitle.localized,
                                        image: "home.uwazi",
                                        destination: UwaziView(uwaziViewModel: uwaziViewModel))
                case .gDrive:
                    ConnectionsItemView(title: LocalizableGDrive.gDriveAppBar.localized,
                                        image: "home.drive",
                                        destination: gDriveMainView)
                case .nextcloud:
                    
                    ConnectionsItemView(title: LocalizableNextcloud.nextcloudAppBar.localized,
                                        image: "home.nextcloud",
                                        destination:nextcloudMainView)
                case .dropbox:
                    ConnectionsItemView(title: LocalizableDropbox.dropboxAppBar.localized,
                                        image: "home.dropbox",
                                        destination: dropboxMainView)
                }
            }
            
            addButton
            
            Spacer()
        }.padding(.trailing, 17)
    }
    
    var reportsMainView: TellaServerReportsMainView { //Check if we can rename it
        TellaServerReportsMainView(reportsMainViewModel: ReportsViewModel(mainAppModel: homeViewModel.mainAppModel))
    }
    
    var gDriveMainView : GdriveReportMainView {
        GdriveReportMainView(reportsMainViewModel: GDriveViewModel(mainAppModel: homeViewModel.mainAppModel, gDriveRepository: GDriveRepository()))
    }
    
    var nextcloudMainView : NextcloudReportMainView {
        NextcloudReportMainView(reportsMainViewModel: NextcloudReportViewModel(mainAppModel: homeViewModel.mainAppModel, nextcloudRepository: NextcloudRepository()))
    }
    
    var dropboxMainView: DropboxReportMainView {
        DropboxReportMainView(reportsMainViewModel: DropboxViewModel(mainAppModel: homeViewModel.mainAppModel,
                                                                     dropboxRepository: DropboxRepository()))
    }
    
    var nearbySharingMainView: NearbySharingMainView {
        NearbySharingMainView(mainAppModel: homeViewModel.mainAppModel)
    }
    
    var addButton: some View {
        Button {
            // Show Connections View()
            let viewModel = ServersViewModel(mainAppModel: homeViewModel.mainAppModel)
            navigateTo(destination: ServersListView(serversViewModel: viewModel))
        } label: {
            Image("home.add")
                .frame(width: 92,height: 92)
        }
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
        ConnectionsView(homeViewModel: HomeViewModel(appViewState: AppViewState.stub()))
    }
}
