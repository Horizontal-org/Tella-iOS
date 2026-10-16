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
    var layout: TellaButtonLayout = .fullWidth
    
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
    init(
        title: String,
        nextButtonAction: NextButtonAction,
        buttonType: ButtonType = .clear,
        isOverlay: Bool = false,
        layout: TellaButtonLayout = .fullWidth,
        destination: Destination,
        isValid: Binding<Bool>,
        action: (() -> ())? = nil
    ) {
        self.title = title
        self.nextButtonAction = nextButtonAction
        self.buttonType = buttonType
        self.isOverlay = isOverlay
        self.layout = layout
        self.destination = destination
        self._isValid = isValid
        self.action = action
    }
    
    // MARK: - Initializer without Destination
    init(
        title: String,
        nextButtonAction: NextButtonAction,
        buttonType: ButtonType = .clear,
        isOverlay: Bool = false,
        layout: TellaButtonLayout = .fullWidth,
        isValid: Binding<Bool>,
        action: (() -> ())? = nil
    ) where Destination == EmptyView {
        self.title = title
        self.nextButtonAction = nextButtonAction
        self.buttonType = buttonType
        self.isOverlay = isOverlay
        self.layout = layout
        self.destination = nil
        self._isValid = isValid
        self.action = action
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
            buttonLabel
        }.cornerRadius(cornerRadius)
            .fixedSize(horizontal: layout == .compact, vertical: false)
            .buttonStyle(TellaButtonStyle(buttonStyle: buttonStyle,
                                          isValid: isValid,
                                          cornerRadius: cornerRadius))
            .disabled(isValid == false)
            .overlay(self.isOverlay ?
                     RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.white, lineWidth: 4) : nil)
    }
    
    private var cornerRadius: CGFloat {
        switch layout {
        case .fullWidth:
            return 20
        case .compact:
            return 25
        }
    }
    
    private var buttonLabel: some View {
        let text = CustomText(title,
                              style: layout == .fullWidth ? .buttonLStyle : .buttonSStyle,
                              color: isValid ? buttonStyle.foregroundColor : buttonStyle.disabledForegroundColor)
            .multilineTextAlignment(.center)
        
        return Group {
            switch layout {
            case .fullWidth:
                text
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, .normal)
                    .padding(.vertical, .normal)
            case .compact:
                text
                    .lineLimit(1)
                    .padding(.normal)
                    .frame(minWidth: 132, minHeight: 51)
            }
        }
        .contentShape(Rectangle())
    }
}

struct TellaButtonStyle : ButtonStyle {
    
    var buttonStyle : TellaButtonStyleProtocol
    var isValid : Bool
    var cornerRadius: CGFloat = 20
    
    func makeBody(configuration: Configuration) -> some View {
        
        configuration.label
            .background(configuration.isPressed ? buttonStyle.pressedBackgroundColor : getBackgroundColor())
            .cornerRadius(cornerRadius)
            .overlay(
                configuration.isPressed && isValid ?
                RoundedRectangle(cornerRadius: cornerRadius).stroke(buttonStyle.overlayColor, lineWidth: 3) :
                    RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.clear, lineWidth: 0)
            )
            .foregroundColor(getForegroundColor())
    }
    
    func getBackgroundColor() -> Color {
        isValid ? buttonStyle.backgroundColor :  buttonStyle.disabledBackgroundColor
    }
    
    func getForegroundColor() -> Color {
        isValid ? buttonStyle.foregroundColor :  buttonStyle.disabledForegroundColor
    }
}

struct TellaButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            TellaButtonView(title: "Ok",
                            nextButtonAction: .action,
                            buttonType: .yellow,
                            isValid: .constant(false))
        }
    }
}

