//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

class HomeViewModel: ObservableObject {

    @Published var isImporting = false
    @Published var showingAddFileSheet = false
    
    let importingContentTypes: [UTType] = [UTType(filenameExtension: "pdf")].compactMap { $0 }
    
    func importFile() {
        isImporting = true
    }

}

struct HomeView: View {

    @Binding var hideAll: Bool
    @ObservedObject var appModel: MainAppModel
    @StateObject var viewModel = HomeViewModel()
    
    init(appModel: MainAppModel, hideAll: Binding<Bool>) {
        self.appModel = appModel
        self._hideAll = hideAll
        setupView()
    }
    
    private func setupView() {
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Color(Styles.Colors.backgroundMain).edgesIgnoringSafeArea(.all)
                VStack(spacing: 0){
                    ScrollView{
                        RecentFilesListView(viewModel: appModel)
                        FileGroupsView(viewModel: appModel)
                    }
                }
                AddFileButtonView(action: {
//                    viewModel.$showingAddFileSheet.toggle()
                    viewModel.importFile()
                })
                    .fileImporter(
                        isPresented: $viewModel.isImporting,
                        allowedContentTypes: viewModel.importingContentTypes,
                        allowsMultipleSelection: true,
                        onCompletion: { result in
                            if let urls = try? result.get() {
                                appModel.fileManager.importFile(files: urls, to: nil)
                            }
                        }
                    )
//                .actionSheet(isPresented: $showingAddFileSheet1) {
//                    addFileActionSheet()
//                }
                //TODO: replace with AddFileBottomSheetFileActions
//                AddFileBottomSheetFileActions(isPresented: $showingAddFileSheet)
            }
            .navigationBarTitle("Tella")
            .navigationBarItems(trailing:
                    HStack(spacing: 8) {
                    Button {
                        hideAll = true
                    } label: {
                        Image("home.close")
                            .imageScale(.large)
                        }
                NavigationLink(destination: SettingsView(viewModel: appModel.settings)) {
                            Image("home.settings")
                                .imageScale(.large)
                            }
                    }.background(Color(Styles.Colors.backgroundMain))
                )
            .background(Color(Styles.Colors.backgroundMain))
        }
    }
    
    func addFileActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Change background"),  buttons: [
            .default(Text("Take Photos/Videos")) {
                self.importFileFromDevice()
            },
            .default(Text("Record Audio")) { },
            .default(Text("Import From Device")) {
            
        },
            .default(Text("Import and delete original")) { },
            .cancel()
        ])
    }
    
    func importFileFromDevice() {
        
    }
    
}

struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    static var previews: some View {
        HomeView(appModel: MainAppModel(), hideAll: HomeView_Previews.$hideAll)
    }
}

