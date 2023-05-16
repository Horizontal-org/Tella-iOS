//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var viewModel : HomeViewModel
    @StateObject var serversViewModel: ServersViewModel
    @EnvironmentObject private var appViewState: AppViewState
    
    init(appModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appModel: appModel))
        _serversViewModel = StateObject(wrappedValue: ServersViewModel(mainAppModel: appModel))
    }
    
    var body: some View {
        
        ContainerView {
          
            VStack() {
                
                     
                Spacer()
                    .frame( height: !viewModel.serverDataItemArray.isEmpty ? 16 : 0 )
                ConnectionsView()
                
                Spacer()
                    .frame( height: (!viewModel.serverDataItemArray.isEmpty && viewModel.getFiles().count > 0) ? 16 : 0 )

                if appModel.settings.showRecentFiles {
                    Spacer()
                        .frame( height: viewModel.getFiles().count > 0 ? 16 : 0 )
                    RecentFilesListView(recentFiles: viewModel.getFiles())
                }
                
                Spacer()
                    .frame(height: 30)
                
                FileGroupsView(shouldShowFilesTitle: viewModel.showingFilesTitle)
                
                if appModel.settings.quickDelete {
                    SwipeToActionView(completion: {
                        if(appModel.settings.deleteVault) {
                            // removes files and folders
                            appModel.removeAllFiles()
                        }
                        
                        if(appModel.settings.deleteServerSettings) {
                            // remove servers connections
                            serversViewModel.deleteAllServersConnection()
                        }
                        
                        appViewState.resetToUnlock()
                    })
                }
            }
        }
        .environmentObject(viewModel)
        .navigationBarTitle(LocalizableHome.appBar.localized, displayMode: .inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView(appModel: MainAppModel())
    }
}
