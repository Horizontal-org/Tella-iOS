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
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    ScrollView{
                        RecentFilesListView(appModel: appModel)
                        FileGroupsView(appModel: appModel)
                    }
                }
                AddFileButtonView(appModel: appModel, rootFile: nil)
            }
            .navigationBarTitle("Tella")
            .navigationBarItems(trailing: navBarButtons)
            .background(Styles.Colors.backgroundMain)
        }
    }

    var navBarButtons: some View {
        HStack(spacing: 20) {
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
        }.background(Styles.Colors.backgroundMain)
    }
    
}

struct AddFileButtonView: View {
    
    @ObservedObject var appModel: MainAppModel
    var rootFile: VaultFile?

    @State var showingDocumentPicker = false
    @State var showingImagePicker = false
    @State var showingAddFileSheet = false
    
    var body: some View {
        VStack{
            importFileActionSheet
            documentPickerView
            imagePickerView
        }
    }
    
    @ViewBuilder
    var documentPickerView: some View {
        if #available(iOS 14.0, *) {
            addFileDocumentImporter
        } else {
            HStack{}
            .sheet(isPresented: $showingDocumentPicker, content: {
                DocumentPickerView { urls in
                    appModel.add(files: urls ?? [], to: rootFile, type: .document)
                }
            })
        }
    }
    
    var imagePickerView: some View {
        HStack{}
        .sheet(isPresented: $showingImagePicker, content: {
            ImagePickerView { image, url in
                showingImagePicker = false
                if let url = url {
                    appModel.add(files: [url], to: rootFile, type: .video)
                }
                if let image = image {
                    appModel.add(image: image, to: rootFile, type: .image)
                }
            }
        })
    }

    @available(iOS 14.0, *)
    var addFileDocumentImporter: some View {
        HStack{}
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [UTType(filenameExtension: "pdf")].compactMap { $0 },
            allowsMultipleSelection: true,
            onCompletion: { result in
                if let urls = try? result.get() {
                    appModel.add(files: urls, to: rootFile, type: .document)
                }
            }
        )
    }

    var importFileActionSheet: some View {
        AddFileYellowButton(action: {
            showingAddFileSheet = true
        })
        .actionSheet(isPresented: $showingAddFileSheet, content: {
            addFileActionSheet
        })
    }
    
    //TODO: replace with AddFileBottomSheetFileActions
    //      AddFileBottomSheetFileActions(isPresented: $showingAddFileSheet)
    var addFileActionSheet: ActionSheet {
        ActionSheet(title: Text("Change background"),  buttons: [
            .default(Text("Take Photos/Videos")) {
                appModel.changeTab(to: .mic)
            },
            .default(Text("Record Audio")) {
                appModel.changeTab(to: .mic)
            },
            .default(Text("Import Image/Video")) {
                showingImagePicker = true
            },
            .default(Text("Import From Device")) {
                showingDocumentPicker = true
            },
//            .default(Text("Import and delete original")) {
//                showingDocumentPicker = true
//            },
            .cancel()
        ])
    }

}

struct HomeView_Previews: PreviewProvider {
    
    @State static var hideAll = true
    static var previews: some View {
        HomeView(appModel: MainAppModel(), hideAll: HomeView_Previews.$hideAll)
    }
}

