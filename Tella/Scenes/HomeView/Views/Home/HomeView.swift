//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var viewModel : HomeViewModel
    
    init(appModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appModel: appModel))
    }

    var body: some View {
        
        ContainerView {
            VStack(spacing: 30) {
                
                VStack(spacing: 15) {
                    if appModel.settings.showRecentFiles {
                        Spacer()
                            .frame( height: viewModel.getFiles().count > 0 ? 15 : 0 )
                        RecentFilesListView(recentFiles: viewModel.getFiles())
                    }
                }
                
                FileGroupsView(shouldShowFilesTitle: viewModel.showingFilesTitle)
                
                if appModel.settings.quickDelete {
                    SwipeToActionView(completion: {
                        appModel.removeAllFiles()
                    })
                }
            }
        }
        .navigationBarTitle("Tella", displayMode: .inline)
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView(appModel: MainAppModel())
    }
}
