//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TellaButtonView<Destination:View> : View {
    
    var title : String
    var nextButtonAction : NextButtonAction
    var buttonType : ButtonType = .clear

    var destination : Destination?
    @Binding var isValid : Bool

    var action : (() -> ())?
    
    
    var buttonStyle : TellaButtonStyleProtocol {
        
        switch  buttonType {
        case .yellow:
            return YellowButtonStyle()
        case .clear:
            return ClearButtonStyle()
        }
    }
    
    var body: some View {
        Button {
            if nextButtonAction == .action && isValid {
                action?()
            }
        } label: {
            Text(title)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth:.infinity)
                .frame(height: 55)
                .contentShape(Rectangle())
                .if(destination != nil && isValid, transform: { view in
                    view.navigateTo(destination: destination)
                })
        }.background(buttonStyle.backgroundColor)
            .cornerRadius(20)
            .buttonStyle(TellaButtonStyle(buttonStyle: buttonStyle, isValid: isValid))
    }
}

struct TellaButtonStyle : ButtonStyle {
    
    var buttonStyle : TellaButtonStyleProtocol
    var isValid : Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed && isValid ? buttonStyle.pressedBackgroundColor : buttonStyle.backgroundColor)
            .cornerRadius(20)
            .overlay(
                configuration.isPressed && isValid ? RoundedRectangle(cornerRadius: 20)
                    .stroke(buttonStyle.overlayColor, lineWidth: 4) : RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct TellaButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TellaButtonView<AnyView>(title: "Ok",
                                 nextButtonAction: .action,
                                 isValid: .constant(true))
            .background(Color.red)
    }
}

