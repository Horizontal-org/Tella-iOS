//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var appModel: MainAppModel
    @EnvironmentObject private var appViewState: AppViewState
    @EnvironmentObject private var sheetManager: SheetManager
    
    @StateObject var viewModel : HomeViewModel
    
    init(appModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(appModel: appModel))
    }
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onAppear {
            viewModel.getFiles()
        }
    }
    
    var contentView: some View {
        VStack() {
            ScrollView {
                VStack {
                    Spacer()
                        .frame( height: !viewModel.serverDataItemArray.isEmpty ? 16 : 0 )
                    ConnectionsView(homeViewModel: viewModel)
                    
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
            }
            
            Spacer()
            
            quickDeleteView
        }
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
    
    var navigationBarView : some View {
        
        HStack(spacing: 0) {
            
            Button() {
                showTopSheetView(content: BackgroundActivitiesView(mainAppModel: appModel))
            } label: {
                Image(viewModel.items.count > 0 ? "home.notification_badge" : "home.notificaiton")
                    .padding()
            }
            
            Spacer()
            
            Text(LocalizableHome.appBar.localized)
                .font(.custom(Styles.Fonts.boldFontName, size: 24))
                .foregroundColor(Color.white)
            
            Spacer()
            
            Button {
                viewModel.items.count > 0 ? showBgEncryptionConfirmationView() : appViewState.resetToUnlock()
            } label: {
                Image("home.close")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
        }.frame(height: 57)
            .padding(.horizontal, 16)
    }
    
    private func showBgEncryptionConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: LocalizableBackgroundActivities.exitSheetTitle.localized,
                               msgText: LocalizableBackgroundActivities.exitSheetExpl.localized,
                               cancelText: LocalizableBackgroundActivities.exitcancelSheetAction.localized,
                               actionText: LocalizableBackgroundActivities.exitDiscardSheetAction.localized, didConfirmAction: {
                appViewState.resetToUnlock()
                sheetManager.hide()
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(appModel: MainAppModel.stub())
    }
}
