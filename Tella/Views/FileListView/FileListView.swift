//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileListView: View {
    
    @ObservedObject var appModel: MainAppModel
    @State var showingSortFilesActionSheet = false
    @State var selectingFiles = false
    
    @State var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @State var viewType: FileViewType = FileViewType.list
    
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
                List {
                    ForEach(VaultFile.sorted(files: files, by: sortBy), id: \.self) { file in
                        NavigationLink(destination: FileDetailView(file: file)){
                            FileListItem(file: file)
                                .frame(height: 50)
                        }
                    }
                    .listRowBackground(Styles.Colors.backgroundMain)
                }
                .listStyle(PlainListStyle())
                .background(Styles.Colors.backgroundMain)
            }
            AddFileButtonView(appModel: appModel)
        }
        .navigationBarTitle("\(rootFile.fileName)")
    }
    
    var topBarButtons: some View {
        HStack(spacing: 0) {
            sortFilesButton
            FileSortMenu(showingSortFilesActionSheet: $showingSortFilesActionSheet,
                         sortBy: $sortBy)
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
            showingSortFilesActionSheet = true
        } label: {
            HStack{
                Text(sortBy.displayName)
                    .foregroundColor(.white)
                sortBy.image
                    .frame(width: 14, height: 14)
            }
        }
        .frame(height: 44)
    }
    
    var selectingFilesButton: some View {
        Button {
            selectingFiles = !selectingFiles
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
            viewType = viewType == .list ? .grid : .list
        } label: {
            HStack{
                viewType.image
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

