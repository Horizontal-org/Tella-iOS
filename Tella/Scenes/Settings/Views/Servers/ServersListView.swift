//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServersListView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel : MainAppModel
    
    @State var shouldShowEditServer : Bool = false
    
    var body: some View {
        
        ContainerView {
            
            VStack(spacing: 0) {
                
                Spacer()
                    .frame(height: 8)
                
                SettingsCardView<AnyView> (cardViewArray: serversView())
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $shouldShowEditServer, content: {
            EditSettingsServerView(appModel: mainAppModel, isPresented: $shouldShowEditServer, server: serversViewModel.currentServer)
        })
        
        .toolbar {
            LeadingTitleToolbar(title: "Servers")
        }
        .environmentObject(serversViewModel)

    }
    
    private func serversView<T>() -> [T] {
        
        var arrayView : [T] = [SettingsAddServerCardView()
            .eraseToAnyView() as! T]
        
        serversViewModel.serverArray.forEach({ server in
            arrayView.append(SettingsServerItemView(title: server.username,action: {showServerActionBottomSheet(server: server)}).eraseToAnyView() as! T)
            
        })
        return arrayView
    }
    
    private func showServerActionBottomSheet(server:Server) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: serverActionItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                
                serversViewModel.currentServer = server
                
                self.handleActions(item : item)
            })
        }
    }
    
    private func showDeleteServerConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Delete “Election monitoring” server?",
                               msgText: "If you delete this server, all draft and submitted forms will be deleted from your device.",
                               cancelText: "CANCEL",
                               actionText: "DELETE", didConfirmAction: {
                serversViewModel.deleteServer()
                sheetManager.hide()
            })
        }
    }
    
    private func handleActions(item: ListActionSheetItem) {
        guard let type = item.type as? ServerActionType else { return  }
        
        switch type {
        case .edit:
            shouldShowEditServer = true
            sheetManager.hide()
        case .delete:
            showDeleteServerConfirmationView()
        }
    }
}

struct ServersListView_Previews: PreviewProvider {
    static var previews: some View {
        ServersListView()
    }
}
