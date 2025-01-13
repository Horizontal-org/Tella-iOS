//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    @StateObject var viewModel : HomeViewModel
    
    init(appModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appModel: appModel))
    }
    
    var body: some View {
        
        ContainerView {
            
            VStack() {
                
                ScrollView{
                    Spacer()
                        .frame( height: !viewModel.serverDataItemArray.isEmpty ? 16 : 0 )
                    ConnectionsView()
                    
                    Spacer()
                        .frame( height: (!viewModel.serverDataItemArray.isEmpty && viewModel.recentFiles.count > 0) ? 16 : 0 )
                    
                    if appModel.settings.showRecentFiles {
                        Spacer()
                            .frame( height: viewModel.recentFiles.count > 0 ? 16 : 0 )
                        RecentFilesListView(recentFiles: $viewModel.recentFiles)
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    FileGroupsView(shouldShowFilesTitle: viewModel.showingFilesTitle)
                }
                
                Spacer()
                
                quickDeleteView
            }
        }
        .onAppear{
            viewModel.getFiles()
        }
        .environmentObject(viewModel)
    }
    
    @ViewBuilder
    var quickDeleteView: some View {
        if appModel.settings.quickDelete {
            SwipeToDeleteActionView(completion: {
                if(appModel.settings.deleteVault) {
                    // removes files and folders
                    viewModel.deleteAllVaultFiles()
                }
                
                if(appModel.settings.deleteServerSettings) {
                    // remove servers connections
                    viewModel.deleteAllServersConnection()
                }
                
                appViewState.resetToUnlock()
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(appModel: MainAppModel.stub())
    }
}
