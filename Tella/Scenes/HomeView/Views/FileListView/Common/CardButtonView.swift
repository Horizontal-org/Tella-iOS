//
//  CardButtonView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/12/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CardButtonView: View {
    
    let title: String
    let description: String
    let buttonTitle: String
    var action : (() -> ())?
    
    var body: some View {
        HStack{
            VStack(alignment: .leading,spacing: 7){
                Text(title)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white).padding(.bottom, -5)
                
                Text(description)
                    .foregroundColor(Color.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button(action: {
                action?()
            }, label: {
                Text(buttonTitle)
                    .foregroundColor(Color.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .padding(EdgeInsets(top: 25, leading: 8, bottom: 25, trailing: 0))
            })
            
        }.padding(.all, 16)
    }
}

#Preview {
    CardButtonView(title: "title", description: "description", buttonTitle: "action")
        .background(Styles.Colors.backgroundMain)
}
