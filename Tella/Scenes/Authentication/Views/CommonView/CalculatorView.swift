//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CalculatorView: View {
    
    @Binding var fieldContent : String
    @Binding var message : String
    @Binding var isValid : Bool
    
    var keyboardNumbers : [PinKeyboardModel] = FirstKeyboardItems
    var keyboardNumbers2 : [PinKeyboardModel] = SecondKeyboardItems
    var action : (() -> Void)?
    
    var body: some View {
        
        VStack(spacing:CalculatorData.calculatorItemSpace) {
            LazyVGrid(columns: CalculatorData.firstColumns,spacing: CalculatorData.calculatorItemSpace) {
                ForEach(keyboardNumbers, id: \.self) { item in
                    getView(item: item)
                }
            }
            
            LazyVGrid(columns: CalculatorData.secondColumns,spacing: CalculatorData.calculatorItemSpace) {
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
        }
            .buttonStyle(PinButtonStyle(enabled: true, item: item)))
    }
    
    func buttonAction(item:PinKeyboardModel)  {
        
        isValid = true
        
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
                .frame(maxWidth: .infinity)
                .padding())
        case .text:
            return AnyView(Text(item.text)
                .frame(maxWidth: .infinity)
                .padding())
        }
    }
    
    func appendPin(pin:String) {
        if self.fieldContent == CalculatorData.initialCharacter  {
            self.fieldContent = ""
        }
        self.fieldContent.append(pin)
    }
    
    func delete(pin:String) {
        self.fieldContent.removeAll()
        self.fieldContent = CalculatorData.initialCharacter
    }
    
    private func validateField( ) {
        
        self.isValid = fieldContent.passwordValidator() && fieldContent.passwordLengthValidator()
        
        if !fieldContent.passwordLengthValidator() {
            message = Localizable.Lock.pinLengthError
            
        } else if !fieldContent.passwordValidator() {
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
        CalculatorView(fieldContent: .constant(""),
                message: .constant("Error"),
                isValid: .constant(false))
    }
}

