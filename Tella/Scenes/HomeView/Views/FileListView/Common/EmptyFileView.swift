//
//  EmptyFileView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/12/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct EmptyFileView: View {
    
    var message : String = ""
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Image("files.empty-list")
            
            Spacer()
                .frame(height: 20)

            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
    }
}

#Preview {
    EmptyFileView(message: "Test")
        .background(Styles.Colors.backgroundMain)

}

