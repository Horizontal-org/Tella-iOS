//
//  FileGridItem.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileGridItem: View {
    
    var file: VaultFile
    var parentFile: VaultFile?
    
    @ObservedObject var appModel: MainAppModel
    @State var showFileInfoActive = false
    
    @Binding var selectingFile : Bool
    @Binding var isSelected : Bool
    @Binding var showingActionSheet: Bool
    @Binding var fileActionMenuType : FileActionMenuType
    @Binding var currentSelectedFile : VaultFile?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                file.recentGridImage
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .trailing) {
                    
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            fileActionMenuType = .single
                            showingActionSheet = true
                            currentSelectedFile = file
                            
                        } label: {
                            Image("files.more")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 6, trailing: 0))
                        }
                    }
                }
                
                if selectingFile {
                    Color.black.opacity(0.32)
                        .frame(width: 80, height: 80)
                        .onTapGesture {
                            isSelected = !isSelected
                        }
                    HStack() {
                        
                        VStack(alignment: .leading) {
                            Image(isSelected ? "files.selected" : "files.unselected")
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(EdgeInsets(top: 6, leading: 6, bottom: 0, trailing: 0))
                            Spacer()
                            
                        }.onTapGesture {
                            isSelected = !isSelected
                        }
                        Spacer()
                    }
                }
            }
            .background((isSelected && selectingFile) ? Color.white.opacity(0.16) : Styles.Colors.backgroundMain)
            
        } .frame(width: 80, height: 80)
    }
    
}

struct FileGridItem_Previews: PreviewProvider {
    static var previews: some View {
        FileGridItem(file: VaultFile(type: FileType.folder, fileName: "test"),
                     appModel: MainAppModel(),
                     selectingFile: .constant(false) ,
                     isSelected: .constant(false),
                     showingActionSheet: .constant(false),
                     fileActionMenuType: .constant(.single) ,
                     currentSelectedFile: .constant(VaultFile(type: FileType.folder, fileName: "test")))
    }
}

