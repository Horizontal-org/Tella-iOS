//
//  GridView.swift
//  Tella
//
//  Created by Thisura Dodangoda on 10/11/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation
import SwiftUI

struct GridView<T: Any>: View{
    
    @State var columns: Int = 3
    @State var spacing: Double = 10.0
    
    // rows x columns
    private var organizedGrid: [[T]] = []
    private var content: ((T) -> (AnyView))?
    
    init(columns: Int, items: [T], @ViewBuilder content: @escaping (T) -> (AnyView)){
        self.columns = columns
        self.content = content
        setupData(items)
    }
    
    mutating private func setupData(_ items: [T]){
        guard self.content != nil else { return }
        
        guard items.count > 0 else {
            organizedGrid = []
            return
        }
        organizedGrid = []
        
        var row: Int = 0
        var column: Int = 0
        
        organizedGrid.append([])
        for item in items{
            organizedGrid[row].append(item)
            
            column += 1
            if column >= columns{
                column = 0
                row += 1
                organizedGrid.append([])
            }
        }
    }
    
    var body: some View {
        GeometryReader { (geometry) in
            let spacingWidth = CGFloat(spacing) * CGFloat(columns - 1)
            let itemWidth = (geometry.size.width - spacingWidth) / CGFloat(columns)
            let itemHeight = itemWidth
            let itemSpacing = spacingWidth / 2.0
            ScrollView {
                VStack {
                    ForEach(0..<organizedGrid.count) { (row: Int) in
                        let columnItems = organizedGrid[row]
                        HStack(spacing: itemSpacing) {
                            ForEach(0..<columnItems.count) { (column: Int) in
                                let item = columnItems[column]
                                content?(item).frame(width: itemWidth, height: itemHeight, alignment: .center)
                            }
                        }.frame(width: geometry.size.width, alignment: .leading)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity).padding(0)
            }
        }
    }
}

extension View{
    fileprivate func Print(_ items: Any...) -> some View{
        print(items)
        return EmptyView()
    }
}
