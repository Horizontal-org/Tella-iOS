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
                    .aspectRatio(1, contentMode: .fill)
                Image(uiImage: iconImage)
            }
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
    
    @Published var folderArray: [VaultFile] = []
}

struct FileListView: View {
    
    @ObservedObject var appModel: MainAppModel
    @StateObject var viewModel = FileListViewModel()
    @State var rootFile: VaultFile
   
    var files: [VaultFile]
    var fileType: FileType?
    var title : String = ""

    init(appModel: MainAppModel, files: [VaultFile], fileType: FileType? = nil, rootFile: VaultFile, title : String = "") {
        self.files = files
        self.fileType = fileType
        self.appModel = appModel
        self.rootFile = rootFile
        self.title = title
    }
    
    //    func setupView() {
    //        UITableView.appearance().separatorStyle = .none
    //        UITableView.appearance().tableFooterView = UIView()
    //        UITableView.appearance().separatorColor = .clear
    //        UITableView.appearance().allowsSelection = false
    //        UITableViewCell.appearance().selectedBackgroundView = UIView()
    //    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            VStack {
                folderListView
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
            
            FileSortMenu(showingSortFilesActionSheet: $viewModel.showingSortFilesActionSheet,
                         sortBy: $viewModel.sortBy)
            
        }
        // .navigationBarTitle("\(rootFile.fileName)")
        .toolbar {
            LeadingTitleToolbar(title: title)
        }
    }
    
    private var folderListView : some View {
        HStack(spacing: 5) {
            
            if viewModel.folderArray.count > 0 {
                Button() {
                    rootFile = appModel.vaultManager.root
                    viewModel.folderArray.removeAll()
                } label: {
                    Image("files.folder")
                        .resizable()
                        .frame(width: 20, height: 16)
                }
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    ForEach(viewModel.folderArray, id:\.self) { file in
                        Text(file.fileName)
                            .foregroundColor(.white).opacity(0.72)
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .onTapGesture {
                                rootFile = file
                                if let index = viewModel.folderArray.firstIndex(of: file) {
                                    viewModel.folderArray.removeSubrange(index + 1..<viewModel.folderArray.endIndex)
                                }
                            }
                        if let index = viewModel.folderArray.firstIndex(of: file), index < viewModel.folderArray.count  - 1 {
                            Image("files.arrow_right")
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            
        }.padding(EdgeInsets(top: 12, leading: 18, bottom: 15, trailing: 18))
        
    }
    
    @available(iOS 14.0, *)
    private var gridLayout: [GridItem] {
        [GridItem(.fixed(80),spacing: 6),
         GridItem(.fixed(80),spacing: 6),
         GridItem(.fixed(80),spacing: 6),
         GridItem(.fixed(80),spacing: 6)]
    }
    
    @available(iOS 14.0, *)
    var itemsGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: 6) {
                ForEach(files.sorted(by: viewModel.sortBy, folderArray: viewModel.folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType), id: \.self) { file in
                    
                    switch file.type {
                    case .folder:
                        file.recentGridImage
                            .background(Color.white.opacity(0.2))
                            .onTapGesture {
                                rootFile = file
                                viewModel.folderArray.append(file)
                            }
                    default:
                        file.recentGridImage
                            .background(Color.white.opacity(0.2))
                            .navigateTo(destination: FileDetailView(appModel: appModel,
                                                                    file: file,
                                                                    fileType: fileType))
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
    }
    
    @State private var selection: String? = nil
    var itemsListView: some View {
        List {
            ForEach(files.sorted(by: viewModel.sortBy, folderArray: viewModel.folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType), id: \.self) { file in
                VStack(alignment: .leading) {
                    
                    switch file.type {
                    case .folder:
                        FileListItem(file: file,
                                     parentFile: rootFile,
                                     appModel: appModel,
                                     selectingFile: $viewModel.selectingFiles,
                                     isSelected: .constant(false))
                            .background(Styles.Colors.backgroundMain)
                            .onTapGesture {
                                rootFile = file
                                viewModel.folderArray.append(file)
                            }
                    default:
                        FileListItem(file: file,
                                     parentFile: rootFile,
                                     appModel: appModel,
                                     selectingFile: $viewModel.selectingFiles,
                                     isSelected: .constant(false) )
//                    isSelected: $files[(files.firstIndex(of: file)!)].isSelected)

                            .background(Styles.Colors.backgroundMain)
                            .navigateTo(destination: FileDetailView(appModel: appModel,
                                                                    file: file,
                                                                    fileType: fileType))
                    }
                }.frame(height: 50)
            }
            .listRowBackground(Styles.Colors.backgroundMain)
        }
        .listStyle(PlainListStyle())
        .background(Styles.Colors.backgroundMain)
    }
    
    var topBarButtons: some View {
        HStack(spacing: 0) {
            sortFilesButton
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

