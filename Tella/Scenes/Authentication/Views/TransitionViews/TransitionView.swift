//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TransitionView: View {
    
    var transitionViewData : TransitionViewData
    
    var action : (() -> (Void))?
    
    var body: some View {
        
        VStack {
           
            Spacer()
            
            Image(transitionViewData.image)
            
            Spacer()
                .frame(height: 42)
            
            Text(transitionViewData.title)
                .font(.custom(Styles.Fonts.boldFontName, size: 32))
                .foregroundColor(.white)
            
            Spacer()
                .frame(height: 8)
            
            Text(transitionViewData.description)
                .font(.custom(Styles.Fonts.regularFontName, size: 16))
                .foregroundColor(.white)
                .multilineTextAlignment(transitionViewData.alignment)
            
            Spacer()
                .frame(height: 50)
            
            Button {
                action?()
            } label: {
                Text(transitionViewData.buttonTitle)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.clear)
            }
            
            .buttonStyle(ReadyButtonStyle())
            
            Spacer()
        }
        .padding(EdgeInsets(top: 0, leading: 25, bottom: 0, trailing: 25))
    }
}

struct ReadyButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.init(red: 216/255, green: 175/255, blue: 116/255) : Styles.Colors.yellow)
            .cornerRadius(20)
            .overlay(configuration.isPressed ? RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.64), lineWidth: 3) : RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0) )
    }
}

struct TransitionView_Previews: PreviewProvider {
    static var previews: some View {
        TransitionView(transitionViewData: OnboardingEndViewData())
    }
}
