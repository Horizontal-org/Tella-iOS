//
//  FileSortSheet.swift
//  Tella
//
//  Created by Amine Info on 21/11/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FileSortMenu: View {
    
    @Binding var showingSortFilesActionSheet: Bool
    @Binding var sortBy: FileSortOptions
    
    var items : [FileSortOptions] = [.nameAZ, .nameZA, .newestToOldest, .oldestToNewest]
    
    var body: some View {
        ZStack{
            DragView(modalHeight: 226,
                     color: Styles.Colors.backgroundTab,
                     isShown: $showingSortFilesActionSheet) {
                FileSortContentView
            }
        }
    }
    
    var FileSortContentView : some View {
        
        VStack(alignment: .leading, spacing: 20) {
            Text("Sort by")
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .padding(EdgeInsets(top: 21, leading: 21, bottom: 0, trailing: 21))
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(items, id : \.self) { item in
                    RadioButtonField(id: item,
                                     label: item.name,
                                     isMarked: item == sortBy) { result in
                        sortBy = result
                        showingSortFilesActionSheet = false
                    }
                }
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 27, trailing: 15))
        }
    }
}

struct RadioButtonField: View {
    let id: FileSortOptions
    let label: String
    let isMarked:Bool
    let callback: (FileSortOptions)->()
    
    init( id: FileSortOptions, label:String, isMarked: Bool = false, callback: @escaping (FileSortOptions)->()) {
        self.id = id
        self.label = label
        self.isMarked = isMarked
        self.callback = callback
    }
    
    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(self.isMarked ? "radio_selected" : "radio_unselected")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 13, height: 13)
                Text(label)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                Spacer()
            }.foregroundColor(.white)
        }
        .foregroundColor(Color.white)
    }
}

struct FileSortSheet_Previews: PreviewProvider {
    static var previews: some View {
        FileSortMenu(showingSortFilesActionSheet: .constant(true), sortBy: .constant(FileSortOptions.nameAZ))
    }
}
