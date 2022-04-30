//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

var calculatorItemWidth: CGFloat = (UIScreen.screenWidth - 13 * 5) / 4
var calculatorItemSpace: CGFloat = 13

struct PinView: View {
    
    let columns = [ GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                    GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                    GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                    GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace)]
    
    let columns2 = [ GridItem(.fixed(calculatorItemWidth * 2 + 13), spacing: calculatorItemSpace),
                     GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace),
                     GridItem(.fixed(calculatorItemWidth),spacing: calculatorItemSpace)]
    
    @Binding var fieldContent : String
    
    var keyboardNumbers : [PinKeyboardModel] = LockKeyboardNumbers
    var keyboardNumbers2 : [PinKeyboardModel] = UnlockKeyboardNumbers
    
    @Binding var message : String
    @Binding var isValid : Bool
    
    var action : (() -> Void)?
    
    var body: some View {
        
        VStack(spacing:calculatorItemSpace) {
            LazyVGrid(columns: columns,spacing: 13) {
                ForEach(keyboardNumbers, id: \.self) { item in
                    getView(item: item)
                }
            }
            
            LazyVGrid(columns: columns2,spacing: 13) {
                ForEach(keyboardNumbers2, id: \.self) { item in
                    getView(item: item)
                }
            }
        }
    }
    
    func getView(item:PinKeyboardModel) -> some View {
        
        return AnyView(Button {
            self.buttonAction(item: item)
        } label: {
            self.getButtonView(item: item)
        }.frame( height: 70)
            .frame(maxWidth: .infinity)
            .buttonStyle(PinButtonStyle(enabled: true, item: item)))
    }
    
    func buttonAction(item:PinKeyboardModel)  {
        switch item.actionType {
            
        case .delete:
            self.delete(pin: item.text)
            
        case .done:
            self.validateField()
            if self.isValid {
                action?()
            }
            
        case .number:
            self.appendPin(pin: item.text)
        }
    }
    
    func getButtonView(item:PinKeyboardModel) -> some View {
        switch item.buttonType {
        case .image:
            return AnyView(Image(item.imageName)
                .padding())
        case .text:
            return AnyView(Text(item.text)
                .frame(maxWidth: .infinity)
                .padding())
        }
    }
    
    func appendPin(pin:String) {
        if self.fieldContent == "0"  {
            self.fieldContent = ""
        }
        self.fieldContent.append(pin)
    }
    
    func delete(pin:String) {
        self.fieldContent.removeAll()
        self.fieldContent = "0"
    }
    
    private func validateField( ) {
        
        self.isValid = fieldContent.passwordValidator() && fieldContent.passwordLengthValidator()
        
        if !fieldContent.passwordLengthValidator() {
            message = Localizable.Lock.pinLengthError
            
        } else if !fieldContent.passwordValidator(){
            message = Localizable.Lock.pinDigitsError
        }
    }
}

struct PinButtonStyle : ButtonStyle {
    
    var enabled : Bool
    var item : PinKeyboardModel
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(item.buttonViewData.font)
            .foregroundColor(item.buttonViewData.fontColor)
            .background(configuration.isPressed ? item.buttonViewData.backgroundColor.opacity(0.4) : item.buttonViewData.backgroundColor)
            .cornerRadius(15)
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(fieldContent: .constant(""),
                message: .constant("Error"),
                isValid: .constant(false))
    }
}

