//
//  FileListViewModel.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation


class FileListViewModel: ObservableObject {
    @Published var showingSortFilesActionSheet = false
    @Published var showingFileActionMenu = false
    @Published var showingFilesSelectionMenu = false
    @Published var selectingFiles = false
    
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var folderArray: [VaultFile] = []
    @Published var filesArray: [VaultFile] = []
    
    
    var selectedItems : Int {
        return filesArray.filter{$0.isSelected}.count
    }
    
}
