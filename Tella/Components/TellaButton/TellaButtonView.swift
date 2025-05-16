//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TellaButtonView<Destination:View> : View {
    
    var title : String
    var nextButtonAction : NextButtonAction
    var buttonType : ButtonType = .clear
    var isOverlay: Bool = false
    
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
    var buttonRole: ButtonRole = .primary
    var body: some View {
        GeometryReader { geometry in
            Button {
                
                UIApplication.shared.endEditing()
                
                if nextButtonAction == .action  {
                    action?()
                }
                if (destination != nil) && nextButtonAction == .destination {
                    navigateTo(destination: destination)
                }
            } label: {
                Text(title)
                    .frame(maxWidth:.infinity)
                    .frame(height: 55)
                    .contentShape(Rectangle())
                
            }
            .cornerRadius(getCornerRadius(geometry: geometry))
            .buttonStyle(TellaButtonStyle(buttonStyle: buttonStyle,
                                          isValid: isValid,
                                          cornerRadius: getCornerRadius(geometry: geometry),
                                          buttonRole: buttonRole))
            .disabled(isValid == false)
            .overlay(self.isOverlay ?
                     RoundedRectangle(cornerRadius: getCornerRadius(geometry: geometry))
                .stroke(.white, lineWidth: 4) : nil)
        }.frame(height: 55)
    }
    
    func getCornerRadius(geometry:GeometryProxy) -> CGFloat {
        return buttonRole == .primary ? 20 : geometry.size.height / 2
    }
}

struct TellaButtonStyle : ButtonStyle {
    
    var buttonStyle : TellaButtonStyleProtocol
    var isValid : Bool
    var cornerRadius: CGFloat = 20
    var buttonRole: ButtonRole = .primary
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .background(configuration.isPressed ? buttonStyle.pressedBackgroundColor : getBackgroundColor())
            .cornerRadius(cornerRadius)
            .overlay(
                configuration.isPressed && isValid ? RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(buttonStyle.overlayColor, lineWidth: 4) : RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.clear, lineWidth: 0)
            )
            .foregroundColor(getForegroundColor())
            .style(buttonRole == .primary ? .buttonLStyle : .buttonSStyle)
    }
    
    func getBackgroundColor() -> Color {
        isValid ? buttonStyle.backgroundColor :  buttonStyle.disabledBackgroundColor
    }
    
    func getForegroundColor() -> Color {
        isValid ? buttonStyle.foregroundColor :  buttonStyle.disabledForegroundColor
    }
    
}

// Convenience initializer for when Destination == EmptyView (no navigation)
extension TellaButtonView where Destination == EmptyView {
    init(
        title: String,
        nextButtonAction: NextButtonAction,
        buttonType: ButtonType = .clear,
        isOverlay: Bool = false,
        isValid: Binding<Bool>,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.nextButtonAction = nextButtonAction
        self.buttonType = buttonType
        self.isOverlay = isOverlay
        self.destination = nil
        self._isValid = isValid
        self.action = action
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

