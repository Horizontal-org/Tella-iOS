//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ServersListView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
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
            EditSettingsServerView(isPresented: $shouldShowEditServer)
        })
        
        .toolbar {
            LeadingTitleToolbar(title: "Servers")
        }
    }
    
    func serversView<T>() -> [T] {
        
        var arrayView : [T] = [SettingsAddServerCardView().environmentObject(serversViewModel).eraseToAnyView() as! T]
        
        serversViewModel.servers?.forEach({ server in
            arrayView.append(SettingsServerItemView(title: server.username,action: showServerActionBottomSheet).eraseToAnyView() as! T)
            
        })
        return arrayView
    }
    
    func showServerActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: serverActionItems,
                                  headerTitle: LocalizableVault.manageFilesSheetTitle.localized,
                                  action:  {item in
                self.handleActionss(item : item)
            })
            
        }
    }
    
    func showDeleteServerConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Delete “Election monitoring” server?",
                               msgText: "If you delete this server, all draft and submitted forms will be deleted from your device.",
                               cancelText: "CANCEL",
                               actionText: "DELETE", didConfirmAction: {
                // Delete action
            })
        }
    }
    
    private func handleActionss(item: ListActionSheetItem) {
        guard let type = item.type as? ServerActionType else { return  }
        
        switch type {
        case .edit:
            shouldShowEditServer = true
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
