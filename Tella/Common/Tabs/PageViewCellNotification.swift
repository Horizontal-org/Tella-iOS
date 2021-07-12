//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PageViewCellNotification: View {
    
    let title: String
    let width: CGFloat
    let page: Pages
    
    @Binding var selectedOption: Pages
    @Binding var outBoxCount: Int
    
    public var body: some View {
        VStack {
            let selected: Bool = page == selectedOption
            HStack(spacing : 2){
                Text(title)
                    .font(Font.system(size: 15))
                    .bold()
                    .foregroundColor(selected ? .white : .gray)
         
                Text("("+String(outBoxCount)+")")
                    .foregroundColor(.yellow)
                    .font(Font.system(size: 12))
                    .bold()
                
            }.padding(.bottom, 1)
            Rectangle()
                .fill(selected ?  Color.white : Color.clear)
                .frame(width: width, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

