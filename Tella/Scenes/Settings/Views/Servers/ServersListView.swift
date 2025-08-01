//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ServersListView: View {
    
    var serversViewModel : ServersViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @State var shouldShowEditServer : Bool = false
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .fullScreenCover(isPresented: $shouldShowEditServer, content: {
            EditSettingsServerView(appModel: serversViewModel.mainAppModel,
                                   isPresented: $shouldShowEditServer,
                                   server: serversViewModel.mainAppModel.tellaData?.getTellaServer(serverId: (serversViewModel.currentServer?.id)!))
        })
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableSettings.settConnections.localized)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 8)
            
            SettingsCardView<AnyView> (cardViewArray: serversView())
            
            Spacer()
        }.scrollOnOverflow()
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
        let items = serverActionItems(server: server)
        let modalHeight = items.count == 1 ? 140 : 175
        sheetManager.showBottomSheet(modalHeight: CGFloat(modalHeight)) {
            ActionListBottomSheet(items: serverActionItems(server: server),
                                  headerTitle: server.name ?? "",
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
            showDeleteServerConfirmationView(server: server)
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
    private func showDeleteServerConfirmationView(server: Server) {
        sheetManager.showBottomSheet(modalHeight: 210) {
            ConfirmBottomSheet(titleText: String(format: LocalizableSettings.settServerDeleteConnectionTitle.localized, server.name ?? ""),
                               msgText: LocalizableSettings.settServerDeleteConnectionMessage.localized,
                               cancelText: LocalizableSettings.settServerCancelSheetAction.localized,
                               actionText: LocalizableSettings.settServerDeleteSheetAction.localized,
                               didConfirmAction: {
                serversViewModel.deleteServer()
            })
        }
    }
    
    fileprivate func navigateToUwaziAddServerView(_ server: UwaziServer) {
        navigateTo(destination: UwaziAddServerURLView(uwaziServerViewModel: UwaziServerViewModel(mainAppModel: serversViewModel.mainAppModel, currentServer: server))
            .environmentObject(serversViewModel))
    }
    private func serverActionItems(server: Server) -> [ListActionSheetItem]{
        var serverActionItems : [ListActionSheetItem] = [
            ListActionSheetItem(imageName: "delete-icon-white",
                                content: LocalizableUwazi.uwaziServerDelete.localized,
                                type: ServerActionType.delete)
            
        ]
        switch server.serverType {
        case .uwazi, .tella:
            serverActionItems.append(ListActionSheetItem(imageName: "edit-icon",
                                                         content: LocalizableUwazi.uwaziServerEdit.localized,
                                                         type: ServerActionType.edit))
        default: break
        }
        return serverActionItems
    }
}

struct ServersListView_Previews: PreviewProvider {
    static var previews: some View {
        ServersListView(serversViewModel: ServersViewModel.stub())
    }
}
