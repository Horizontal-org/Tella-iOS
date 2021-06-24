//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

extension VaultFile {
    var gridImage: AnyView {
        AnyView(
            ZStack{
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .scaledToFit()
                Image(uiImage: iconImage)
            }
            .background(Color.gray)
        )
    }
}

class FileListViewModel: ObservableObject {
    @Published var showingSortFilesActionSheet = false
    @Published var showingFileActionMenu = false
    @Published var showingFilesSelectionMenu = false
    @Published var selectingFiles = false
    
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @Published var viewType: FileViewType = FileViewType.list
}

struct FileListView: View {
    
    @ObservedObject var appModel: MainAppModel
    @ObservedObject var viewModel = FileListViewModel()

    var rootFile: VaultFile
    var fileType: FileType?
    var files: [VaultFile]
    
    init(appModel: MainAppModel, files: [VaultFile], fileType: FileType? = nil, rootFile: VaultFile) {
        self.files = files
        self.fileType = fileType
        self.appModel = appModel
        self.rootFile = rootFile
    }
    
    func setupView() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().allowsSelection = false
        UITableViewCell.appearance().selectedBackgroundView = UIView()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            VStack {
                topBarButtons
                if #available(iOS 14.0, *) {
                    if viewModel.viewType == .list {
                        itemsListView
                    } else {
                        itemsGridView
                    }
                } else {
                    itemsListView
                }
            }
            AddFileButtonView(appModel: appModel, rootFile: rootFile)
        }
        .navigationBarTitle("\(rootFile.fileName)")
    }

    @available(iOS 14.0, *)
    private var gridLayout: [GridItem] {
        [GridItem(.adaptive(minimum: 87))]
    }
    
    @available(iOS 14.0, *)
    var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 6) {
                ForEach(VaultFile.sorted(files: files, by: viewModel.sortBy), id: \.self) { file in
                    NavigationLink(
                        destination: FileDetailView(file: file)) {
                        file.gridImage
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(maxHeight: 300)
                            .cornerRadius(5)
                            .background(Styles.Colors.backgroundMain)
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
    }
    
    var itemsListView: some View {
        List {
            ForEach(VaultFile.sorted(files: files, by: viewModel.sortBy), id: \.self) { file in
                ZStack(alignment: .leading) {
                    NavigationLink(
                        destination: FileDetailView(file: file)) {
                        EmptyView()
                    }
                    .opacity(0)
                    .background(Styles.Colors.backgroundMain)
                    FileListItem(file: file)
                }
                .frame(height: 50)
            }
            .listRowBackground(Styles.Colors.backgroundMain)
        }
        .listStyle(PlainListStyle())
        .background(Styles.Colors.backgroundMain)
    }
    
    var topBarButtons: some View {
        HStack(spacing: 0) {
            sortFilesButton
            FileSortMenu(showingSortFilesActionSheet: $viewModel.showingSortFilesActionSheet,
                         sortBy: $viewModel.sortBy)
            Spacer()
            selectingFilesButton
            if #available(iOS 14.0, *) {
                viewTypeButton
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .background(Styles.Colors.backgroundMain)
    }

    var sortFilesButton: some View {
        Button {
            viewModel.showingSortFilesActionSheet = true
        } label: {
            HStack{
                Text(viewModel.sortBy.displayName)
                    .foregroundColor(.white)
                viewModel.sortBy.image
                    .frame(width: 14, height: 14)
            }
        }
        .frame(height: 44)
    }
    
    var selectingFilesButton: some View {
        Button {
            viewModel.selectingFiles = !viewModel.selectingFiles
        } label: {
            HStack{
                Image("files.selectingFiles")
                    .frame(width: 24, height: 24)
            }
        }
            .frame(width: 44, height: 44)
    }
    
    var viewTypeButton: some View {
        Button {
            viewModel.viewType = viewModel.viewType == .list ? FileViewType.grid : FileViewType.list
        } label: {
            HStack{
                viewModel.viewType.image
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 44, height: 44)
    }
    
}

struct FileListView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            ZStack(alignment: .top) {
                Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
                FileListView(appModel: MainAppModel(), files: VaultFile.stubFiles(), rootFile: VaultFile.stub(type: .folder))
            }
            .navigationBarTitle("Tella")
            .background(Styles.Colors.backgroundMain)
        }
    }
}

