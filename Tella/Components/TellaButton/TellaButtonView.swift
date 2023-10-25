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
            
            UIApplication.shared.endEditing()

            if nextButtonAction == .action  {
                action?()
            }
            if (destination != nil) {
                navigateTo(destination: destination)
            }
        } label: {
            Text(title)
                .frame(maxWidth:.infinity)
                .frame(height: 55)
                .contentShape(Rectangle())
            
        }.cornerRadius(20)
            .buttonStyle(TellaButtonStyle(buttonStyle: buttonStyle, isValid: isValid))
            .disabled(isValid == false)
    }
}

struct TellaButtonStyle : ButtonStyle {
    
    var buttonStyle : TellaButtonStyleProtocol
    var isValid : Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? buttonStyle.pressedBackgroundColor : getBackgroundColor())
            .cornerRadius(20)
            .overlay(
                configuration.isPressed && isValid ? RoundedRectangle(cornerRadius: 20)
                    .stroke(buttonStyle.overlayColor, lineWidth: 4) : RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
            .foregroundColor(isValid ? .white : .white.opacity(0.38))
            .font(.custom(Styles.Fonts.boldFontName, size: 16))
    }
    
    func getBackgroundColor() -> Color {
        isValid ? buttonStyle.backgroundColor :  buttonStyle.disabledBackgroundColor
    }
}

struct TellaButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            TellaButtonView<AnyView>(title: "Ok",
                                     nextButtonAction: .action,
                                     buttonType: .yellow,
                                     isValid: .constant(false))
        }
    }
}

