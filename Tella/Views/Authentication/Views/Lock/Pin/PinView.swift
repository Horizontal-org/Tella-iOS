//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PinView: View {
    
    let columns = [ GridItem(.fixed(70),spacing: 40),
                    GridItem(.fixed(70),spacing: 40),
                    GridItem(.fixed(70),spacing: 40)]
    
    @Binding var fieldContent : String
    var keyboardNumbers : [PinKeyboardModel]
    var action : (() -> Void)?
    
    
    var body: some View {
        
        LazyVGrid(columns: columns,spacing: 10) {
            
            ForEach(keyboardNumbers, id: \.self) { item in
                switch item.type {
                case .delete:
                    Button {
                        self.delete(pin: item.text)
                    } label: {
                        Image(item.imageName)
                    }.buttonStyle(PinButtonStyle())
                        .disabled(!(self.fieldContent.count>0))
                        .padding(13)
                    
                case .number:
                    Button {
                        self.appendPin(pin: item.text)
                    } label: {
                        Text(item.text)
                    }
                    .padding(13)
                    .buttonStyle(PinButtonStyle())
                    
                case .done:
                    Button {
                        action?()
                    } label: {
                        Text(item.text)
                            .foregroundColor(self.fieldContent.passwordValidator() ? .white : .white.opacity(0.24) )
                    }.buttonStyle(PinButtonStyle())
                        .padding(13)
                        .disabled(!self.fieldContent.passwordValidator())
                    
                default:
                    Text("")
                }
            }
        }
    }
    
    func appendPin(pin:String) {
        self.fieldContent.append(pin)
    }
    
    func delete(pin:String) {
        self.fieldContent.removeLast()
    }
}

struct PinButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(Styles.Fonts.lightRobotoFontName, size: 32))
            .foregroundColor(configuration.isPressed ? .gray : .white)
        
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(fieldContent: .constant(""),
                keyboardNumbers: LockKeyboardNumbers)
    }
}

