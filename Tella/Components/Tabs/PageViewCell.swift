//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct  PageViewCell: View {
    
    let title: String
    let number: Int
    
    let page: Pages
    
    @Binding var selectedOption: Pages
    
    public var body: some View {
        
        Button(action: {
            self.selectedOption = page
        }, label: {
            
            let selected: Bool = page == selectedOption
            VStack {
                HStack(spacing: 3) {
                    Text(title)
                        .font(.custom(Styles.Fonts.boldFontName, size: 15))
                        .foregroundColor(selected ? .white : .white.opacity(0.5))
                        .padding(.bottom, 1)
                    if number > 0 {
                        Text("(\(number))")
                            .font(.custom(Styles.Fonts.boldFontName, size: 15))
                            .foregroundColor(Styles.Colors.yellow)
                    }
                } .frame(height: 20)
                Rectangle()
                    .fill(selected ?  Color.white : Color.clear)
                    .frame(height: 4, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            }.fixedSize()
        })
    }
}



