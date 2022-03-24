//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

class HomeViewModel: ObservableObject {
    @Published var showingDocumentPicker = false
    @Published var showingAddFileSheet = false
}

struct HomeView: View {

    @EnvironmentObject var appModel: MainAppModel
    @StateObject var viewModel = HomeViewModel()

    var body: some View {
        
        ContainerView {
            VStack(spacing: 30) {
                
                VStack(spacing: 15) {
                    Spacer()
                        .frame( height: appModel.vaultManager.recentFiles.count > 0 ? 15 : 0 )
                    RecentFilesListView()
                }
                
                FileGroupsView()
                
                if appModel.settings.quickDelete {
                    SwipeToActionView(completion: {
                        appModel.removeAllFiles()
                    })
                }
                
                fileListWithTypeView
            }
        }
        .navigationBarTitle("Tella", displayMode: .inline)
    }

    var  fileListWithTypeView : some View {
        NavigationLink(destination: FileListView(appModel: appModel,
                                                 rootFile: appModel.vaultManager.root,
                                                 fileType: appModel.selectedType,
                                                 title: appModel.selectedType.getTitle())
                       , isActive: $appModel.showFilesList) {
            EmptyView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
    }
}
