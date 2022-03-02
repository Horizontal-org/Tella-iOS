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

struct FileListView: View {
    
    @ObservedObject var appModel: MainAppModel
    @StateObject var viewModel = FileListViewModel()
    @State var rootFile: VaultFile
    
    var files: [VaultFile]
    var fileType: [FileType]?
    var title : String = ""
    
    private var selectedItemsTitle : String {
        return viewModel.selectedItemsNumber == 1 ? "\(viewModel.selectedItemsNumber) item" : "\(viewModel.selectedItemsNumber) items"
    }
    
    private var filteredArray : [VaultFile] {
        return files.sorted(by: viewModel.sortBy, folderArray: viewModel.folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType)
    }
    
    init(appModel: MainAppModel, files: [VaultFile], fileType: [FileType]? = nil, rootFile: VaultFile, title : String = "") {
        self.files = files
        self.fileType = fileType
        self.appModel = appModel
        self.rootFile = rootFile
        self.title = title
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            VStack {
                selectingFilesHeaderView
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
            AddFileView(appModel: appModel,
                              rootFile: rootFile,
                              selectingFiles: $viewModel.selectingFiles)
            
            FileSortMenu(showingSortFilesActionSheet: $viewModel.showingSortFilesActionSheet,
                         sortBy: $viewModel.sortBy)
            
            FileActionMenu(selectedFiles:viewModel.selectedItems,
                           parentFile: rootFile,
                           fileActionMenuType: viewModel.fileActionMenuType,
                           showingActionSheet: $viewModel.showingFileActionMenu,
                           showFileInfoActive: $viewModel.showFileInfoActive,
                           appModel: appModel)
            showFileDetailsLink
            showFileInfoLink
            
            
        }
        // .navigationBarTitle("\(rootFile.fileName)")
        .toolbar {
            LeadingTitleToolbar(title: title)
        }
        
        .navigationBarHidden(viewModel.selectingFiles)
    }
    @ViewBuilder
    private var selectingFilesHeaderView : some View {
        
        if  viewModel.selectingFiles {
            HStack{
                Button {
                    viewModel.selectingFiles = false
                    viewModel.resetSelectedItems()
                } label: {
                    Image("close")
                }
                
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width: 12)
                if viewModel.selectedItemsNumber > 0 {
                    
                    Text(selectedItemsTitle)
                        .foregroundColor(.white).opacity(0.8)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                }
                Spacer(minLength: 15)
                
                Button {
                    
                } label: {
                    Image("add-to-library")
                }
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width:15)
                
                Button {
                    
                } label: {
                    Image("share-icon")
                }
                .frame(width: 24, height: 24)
                
                Spacer()
                    .frame(width:15)
                
                Button {
                    viewModel.fileActionMenuType = .multiple
                    viewModel.showingFileActionMenu = true
                } label: {
                    Image("files.more")
                        .renderingMode(.template)
                        .foregroundColor((viewModel.selectedItemsNumber == 0) ? .white.opacity(0.5) : .white)
                    
                }.disabled(viewModel.selectedItemsNumber == 0)
                    .frame(width: 24, height: 24)
                
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 23))
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
                        
                        FileGridItem(file: file,
                                     parentFile: rootFile,
                                     appModel: appModel,
                                     selectingFile: $viewModel.selectingFiles,
                                     isSelected: getStatus(for: file),
                                     showingActionSheet: $viewModel.showingFileActionMenu,
                                     fileActionMenuType: $viewModel.fileActionMenuType,
                                     currentSelectedFile: $viewModel.currentSelectedVaultFile)
                        
                            .onTapGesture {
                                rootFile = file
                                viewModel.folderArray.append(file)
                            }
                    default:
                        ZStack {
                            FileGridItem(file: file,
                                         parentFile: rootFile,
                                         appModel: appModel,
                                         selectingFile: $viewModel.selectingFiles,
                                         isSelected: getStatus(for: file),
                                         showingActionSheet: $viewModel.showingFileActionMenu,
                                         fileActionMenuType: $viewModel.fileActionMenuType,
                                         currentSelectedFile: $viewModel.currentSelectedVaultFile)
                            
                                .onTapGesture {
                                    viewModel.showFileDetails = true
                                    self.viewModel.currentSelectedVaultFile = file
                                }
                        }
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
    }
    
    private var itemsListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(files.sorted(by: viewModel.sortBy, folderArray: viewModel.folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType), id: \.self) { file in
                    switch file.type {
                    case .folder:
                        FileListItem(file: file,
                                     parentFile: rootFile,
                                     appModel: appModel,
                                     viewModel: self.viewModel,
                                     showFileInfoActive: $viewModel.showFileInfoActive,
                                     selectingFile: $viewModel.selectingFiles,
                                     isSelected: getStatus(for: file),
                                     showingActionSheet: $viewModel.showingFileActionMenu,
                                     fileActionMenuType: $viewModel.fileActionMenuType,
                                     currentSelectedFile: $viewModel.currentSelectedVaultFile)
                            .frame(height: 60)
                            .onTapGesture {
                                rootFile = file
                                viewModel.folderArray.append(file)
                            }
                        
                    default:
                        FileListItem(file: file,
                                     parentFile: rootFile,
                                     appModel: appModel,
                                     viewModel: self.viewModel,
                                     showFileInfoActive: $viewModel.showFileInfoActive,
                                     selectingFile: $viewModel.selectingFiles,
                                     isSelected: getStatus(for: file),
                                     showingActionSheet: $viewModel.showingFileActionMenu,
                                     fileActionMenuType: $viewModel.fileActionMenuType,
                                     currentSelectedFile: $viewModel.currentSelectedVaultFile)
                            .frame(height: 60)
                            .onTapGesture {
                                viewModel.showFileDetails = true
                                self.viewModel.currentSelectedVaultFile = file
                            }
                    }
                }
                .listRowBackground(Color.green)
            }
        }
        .background(Styles.Colors.backgroundMain)
    }
    
    private var topBarButtons: some View {
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
    
    private var sortFilesButton: some View {
        Button {
            viewModel.showingSortFilesActionSheet = true
        } label: {
            HStack{
                Text(viewModel.sortBy.displayName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14) )
                    .foregroundColor(.white)
                viewModel.sortBy.image
                    .frame(width: 20, height: 20)
            }
        }
        .frame(height: 44)
    }
    
    private var selectingFilesButton: some View {
        Button {
            viewModel.selectingFiles = !viewModel.selectingFiles
            viewModel.resetSelectedItems()
        } label: {
            HStack{
                Image("files.selectingFiles")
                    .frame(width: 24, height: 24)
            }
        }
        .frame(width: 44, height: 44)
    }
    
    private var viewTypeButton: some View {
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
    
    private func getStatus(for file:VaultFile) -> Binding<Bool> {
        if let index = viewModel.vaultFileStatusArray.firstIndex(where: {$0.file == file })   {
            return  $viewModel.vaultFileStatusArray[index].isSelected
        } else {
            viewModel.vaultFileStatusArray.append(VaultFileStatus(file:file,isSelected:false))
            return  $viewModel.vaultFileStatusArray[viewModel.vaultFileStatusArray.count - 1].isSelected
        }
    }
    
    @ViewBuilder
    private var showFileDetailsLink: some View {
        if let currentSelectedVaultFile = self.viewModel.currentSelectedVaultFile {
            NavigationLink(destination:
                            FileDetailView(appModel: appModel,
                                           file: currentSelectedVaultFile,
                                           videoFilesArray: rootFile.getVideos().sorted(by: viewModel.sortBy),
                                           fileType: fileType),
                           isActive: $viewModel.showFileDetails) {
                EmptyView()
            }.frame(width: 0, height: 0)
                .hidden()
        }
    }
    
    @ViewBuilder
    private var showFileInfoLink : some View{
        if let currentSelectedVaultFile = viewModel.currentSelectedVaultFile {
            NavigationLink(destination:
                            FileInfoView(viewModel: self.viewModel, file: currentSelectedVaultFile),
                           isActive: $viewModel.showFileInfoActive) {
                EmptyView()
            }.frame(width: 0, height: 0)
                .hidden()
        }
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

