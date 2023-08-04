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
            EditSettingsServerView(appModel: mainAppModel, isPresented: $shouldShowEditServer, server: serversViewModel.currentServer)
        })
        
        .toolbar {
            LeadingTitleToolbar(title: "Servers")
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
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: serverActionItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                
                serversViewModel.currentServer = server
                
                self.handleActions(item : item, server: server)
            })
        }
    }
    
    private func showDeleteServerConfirmationView(server: Server) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Delete \(server.name ?? "N/A") server?",
                               msgText: "If you delete this server, all draft and submitted forms will be deleted from your device.",
                               cancelText: "CANCEL",
                               actionText: "DELETE", didConfirmAction: {
                serversViewModel.deleteServer()
                sheetManager.hide()
            })
        }
    }
    
    private func handleActions(item: ListActionSheetItem, server: Server) {
        guard let type = item.type as? ServerActionType else { return  }
        
        switch type {
        case .edit:
            if (server.serverType == ServerConnectionType.uwazi.rawValue) {
                navigateTo(destination: UwaziAddServerURLView(appModel: mainAppModel, server: server)
                    .environmentObject(serversViewModel))
                sheetManager.hide()
                return
            }
            shouldShowEditServer = true
            sheetManager.hide()
        case .delete:
            showDeleteServerConfirmationView(server: server)
        }
    }
}

struct ServersListView_Previews: PreviewProvider {
    static var previews: some View {
        ServersListView()
    }
}
