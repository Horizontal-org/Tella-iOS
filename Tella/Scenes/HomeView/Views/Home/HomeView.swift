//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var sheetManager: SheetManager
    
    @ObservedObject var viewModel: HomeViewModel

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
                    
                    if viewModel.mainAppModel.settings.showRecentFiles {
                        Spacer()
                            .frame( height: viewModel.recentFiles.count > 0 ? 16 : 0 )
                        RecentFilesListView(mainAppModel: viewModel.mainAppModel,
                                            recentFiles: $viewModel.recentFiles)
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    FileGroupsView(mainAppModel: viewModel.mainAppModel, shouldShowFilesTitle: viewModel.showingFilesTitle)
                }
            }
            
            Spacer()
            
            quickDeleteView
        }
    }
    
    @ViewBuilder
    var quickDeleteView: some View {
        if viewModel.mainAppModel.settings.quickDelete {
            SwipeToDeleteActionView(completion: {
                if(viewModel.mainAppModel.settings.deleteVault) {
                    // removes files and folders
                    viewModel.deleteAllVaultFiles()
                }
                
                if(viewModel.mainAppModel.settings.deleteServerSettings) {
                    // remove servers connections
                    viewModel.deleteAllServersConnection()
                }
                
                viewModel.appViewState.resetToUnlock()
            })
        }
    }
    
    var navigationBarView : some View {
        
        HStack(spacing: 0) {
            
            Button() {
                showTopSheetView(content: BackgroundActivitiesView(mainAppModel: viewModel.mainAppModel))
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
                viewModel.items.count > 0 ? showBgEncryptionConfirmationView() : viewModel.appViewState.resetToUnlock()
            } label: {
                Image("home.close")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
            }
        }.frame(height: 57)
            .padding(.horizontal, 16)
    }
    
    private func showBgEncryptionConfirmationView() {
        sheetManager.showBottomSheet() {
            ConfirmBottomSheet(titleText: LocalizableBackgroundActivities.exitSheetTitle.localized,
                               msgText: LocalizableBackgroundActivities.exitSheetExpl.localized,
                               cancelText: LocalizableBackgroundActivities.exitcancelSheetAction.localized,
                               actionText: LocalizableBackgroundActivities.exitDiscardSheetAction.localized, didConfirmAction: {
                viewModel.appViewState.resetToUnlock()
                sheetManager.hide()
            })
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(viewModel: HomeViewModel.stub())
//    }
//}
