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
    
    @Binding var hideAll: Bool
    
    @EnvironmentObject var appModel: MainAppModel
    @StateObject var viewModel = HomeViewModel()
    
    init( hideAll: Binding<Bool>) {
        self._hideAll = hideAll
        setupView()
    }
    
    private func setupView() {
        
    }
    
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
    
    var TopBarView: some View {
        
        HStack {
            NavigationLink(destination: SettingsView(appModel: appModel)) {
                Image("home.settings")
                    .frame(width: 19, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 12, leading: 17, bottom: 10, trailing: 17))
            }
            
            Spacer()
            
            Text("Tella")
                .font(.custom(Styles.Fonts.boldFontName, size: 24))
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button {
                hideAll = true
            } label: {
                Image("home.close")
                    .imageScale(.large)
            }.padding(EdgeInsets(top: 12, leading: 17, bottom: 21, trailing: 17))
        }
    }
    
    var  fileListWithTypeView : some View {
        NavigationLink(destination: FileListView(appModel: appModel,
                                                 rootFile: appModel.vaultManager.root,
                                                 fileType: appModel.selectedType,
                                                 title: LocalizableHome.audioItem.localized)
                       , isActive: $appModel.showFilesList) {
            EmptyView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    static var previews: some View {
        HomeView(hideAll: HomeView_Previews.$hideAll)
    }
}
