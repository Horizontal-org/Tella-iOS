//
//  BlueButtonView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/8/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct BlueButtonView<Destination:View> : View {
    
    var title : String
    var destination : Destination?
    
    var body: some View {
        
        Button {
            
        } label: {
            Text(title)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height:55)
                .navigateTo(destination: destination)
            
        }.background( Color.white.opacity(0.16))
            .cornerRadius(20)
            .buttonStyle(BlueButtonStyle())
    }
}

struct BlueButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.32) : Color.white.opacity(0.16))
            .cornerRadius(20)
            .overlay(
                configuration.isPressed ? RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.64), lineWidth: 3) :  RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct BlueButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BlueButtonView<AnyView>(title: "Ok")
    }
}
