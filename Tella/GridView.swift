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
    @State var padding: Double = 10.0
    
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
        VStack(alignment: .leading) {
            ForEach(0..<organizedGrid.count) { (row: Int) in
                let columnItems = organizedGrid[row]
                HStack {
                    ForEach(0..<columnItems.count) { (column: Int) in
                        let item = columnItems[column]
                        content?(item).frame(width: 100, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
                    }
                }
            }
        }
    }
}
