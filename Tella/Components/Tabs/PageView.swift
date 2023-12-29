//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

class PageViewItem {
    
    var title : String
    var page : Int
    var number : String
    
    init(title: String, page: Int, number: String) {
        self.title = title
        self.page = page
        self.number = number
    }
}

public struct PageView: View {
    
    @Binding var selectedOption: Int
    @Binding var pageViewItems : [PageViewItem]
    
    public var body: some View {
        HStack(spacing: 20) {
            ForEach(pageViewItems,id:\.page) { item in
                PageViewCell(title: item.title, number: item.number, page: item.page, selectedOption: $selectedOption)
            }
        }
    }
}

