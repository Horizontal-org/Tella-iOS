//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct  PageViewCell: View {
    let title: String
    let width: CGFloat
    let page: Pages
    @Binding var selectedOption: Pages
    
    public var body: some View {
        VStack {
            let selected: Bool = page == selectedOption
            Text(title)
                .font(Font.system(size: 15))
                .bold()
                .foregroundColor(selected ? .white : .gray)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.bottom, 1)
            Rectangle()
                .fill(selected ?  Color.white : Color.clear)
                .frame(width: width, height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}



