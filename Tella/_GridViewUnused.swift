//
//  GridView.swift
//  Tella
//
//  Created by Thisura Dodangoda on 10/11/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation
import SwiftUI

class GridViewCellModel{
    enum CellState{
        case initial, loading, content
    }
    var data: Data?
    var fileType: FileTypeEnum?
    @State var state: CellState = .initial
    
}

class GridViewModel<T: Hashable>: ObservableObject{
    var columns: Int = 3
    var spacing: CGFloat = 10.0
    @Published var rows: Int = 0
    @Published var overflowColumns: Int = 0
    @Binding var items: [T]{
        didSet{
            recalculateArrangedModel()
        }
    }
    private var arrangedModel: [[T]] = []
    
    init(_ columns: Int, _ items: Binding<[T]>){
        self.columns = columns
        self._items = items
    }
    
    func recalculateArrangedModel(){
        guard items.count > 0 else {
            arrangedModel = []
            return
        }
        arrangedModel = []
        
        var row: Int = 0
        var column: Int = 0
        
        arrangedModel.append([])
        for item in items{
            arrangedModel[row].append(item)
            
            column += 1
            if column >= columns{
                column = 0
                row += 1
                arrangedModel.append([])
            }
        }
        
        rows = arrangedModel.count
        overflowColumns = columns
    }
}

struct GridView<T: Hashable>: View{
    // private var columns: Int = 3
    // private var spacing: Double = 10.0
    
    // @Binding private var items: [T]
    private var viewModel: GridViewModel<T>
    // rows x columns
    // private var organizedGrid: [[T]] = []
    private var content: ((T) -> (AnyView))?
    
    @Binding private var noOfRows: Int
    @Binding private var overflowColumns: Int
    
    //init(columns: Int, items: Binding<[T]>, @ViewBuilder content: @escaping (T) -> (AnyView)){
    /*
    init(columns: Int, viewModel: Binding<GridViewModel<T>>, @ViewBuilder content: @escaping (T) -> (AnyView)){
        self.columns = columns
        self.content = content
        // setupData(items)
        self._viewModel = viewModel
        // self._items = items
    }*/
    init(_ viewModel: GridViewModel<T>,  @ViewBuilder content: @escaping (T) -> (AnyView)){
        self.viewModel = viewModel
        self.content = content
        
        self.noOfRows = viewModel.rows
        self.overflowColumns = viewModel.overflowColumns
    }
    
    var body: some View {
        GeometryReader { (geometry) in
            VStack{
                ForEach(0..<noOfRows) { _ in
                    Rectangle().background(Color.red)
                }
            }
        }
    }
    
    /*
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
    }*/
    
    /*
    var body: some View {
        GeometryReader { (geometry) in
            let spacingWidth = CGFloat(spacing) * CGFloat(columns - 1)
            let itemWidth = (geometry.size.width - spacingWidth) / CGFloat(columns)
            let itemHeight = itemWidth
            let itemSpacing = spacingWidth / 2.0
            
            ScrollView {
                generateContent(geometry.size.width, itemWidth, itemHeight, itemSpacing)
            }
            /*
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
            }*/
        }
    }*/
    
    /*
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
    }*/
}

extension View{
    fileprivate func Print(_ items: Any...) -> some View{
        print(items)
        return EmptyView()
    }
}
