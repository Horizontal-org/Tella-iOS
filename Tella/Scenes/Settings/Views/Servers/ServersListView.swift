//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServersListView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var settingViewModel : SettingsViewModel
    
    @State var shouldShowEditServer : Bool = false
    
    var body: some View {
        
        ContainerView {
            ScrollView {
                VStack(spacing: 0) {
                    
                    Spacer()
                        .frame(height: 8)
                    
                    SettingsCardView<AnyView> (cardViewArray: serversView())
                    
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowEditServer, content: {
            EditSettingsServerView(appModel: mainAppModel, isPresented: $shouldShowEditServer, server: mainAppModel.tellaData?.getTellaServer(serverId: (serversViewModel.currentServer?.id)!))
        })
        
        .toolbar {
            LeadingTitleToolbar(title: LocalizableSettings.settConnections.localized)
        }
    }
    
    private func serversView<T>() -> [T] {
        
        var arrayView : [T] = [SettingsAddServerCardView().environmentObject(serversViewModel)
            .eraseToAnyView() as! T]
        
        serversViewModel.serverArray.forEach({ server in
            arrayView.append(SettingsServerItemView(title: server.name,action: {showServerActionBottomSheet(server: server)}).eraseToAnyView() as! T)
            
        })
        return arrayView
    }
    
    private func showServerActionBottomSheet(server:Server) {
        let filteredActionItems = server.serverType == .gDrive ? serverActionItems.filter { $0.type as? ServerActionType != .edit } : serverActionItems
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: filteredActionItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                
                serversViewModel.currentServer = server
                self.handleActions(item : item, server: server)
            })
        }
    }
    private func handleActions(item: ListActionSheetItem, server: Server) {
        guard let type = item.type as? ServerActionType else { return  }
        switch type {
        case .edit:
            handleEditServer(server)
            sheetManager.hide()
        case .delete:
            let deleteMessages = DeleteServerTexts(server: server)
            showDeleteServerConfirmationView(message: deleteMessages)
        }
    }

    fileprivate func handleEditServer(_ server: Server) {
        guard let serverType = server.serverType else { return }
        switch serverType {
        case .tella:
            shouldShowEditServer = true
        case .uwazi:
            guard let server = server as? UwaziServer else {return}
            navigateToUwaziAddServerView( server)
                
        default:
            break
        }
    }
    private func showDeleteServerConfirmationView(message: DeleteServerTexts) {
        sheetManager.showBottomSheet(modalHeight: 210) {
            ConfirmBottomSheet(titleText: message.titleText,
                                      msgText: message.messageText,
                                      cancelText: message.cancelText,
                                      actionText: message.actionText, didConfirmAction: {
                serversViewModel.deleteServer()
            })
        }
    }

    fileprivate func navigateToUwaziAddServerView(_ server: UwaziServer) {
        navigateTo(destination: UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: mainAppModel, currentServer: server))
            .environmentObject(serversViewModel))
    }
}

struct ServersListView_Previews: PreviewProvider {
    static var previews: some View {
        ServersListView()
    }
}
