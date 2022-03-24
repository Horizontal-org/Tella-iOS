//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PinView: View {
    
    let columns = [ GridItem(.fixed(90),spacing: 20),
                    GridItem(.fixed(90),spacing: 20),
                    GridItem(.fixed(90),spacing: 20)]
    
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
                    }
                    .disabled(!(self.fieldContent.count>0))
                    .frame(width: 70, height: 70)
                    
                case .number:
                    Button {
                        self.appendPin(pin: item.text)
                    } label: {
                        Text(item.text)
                    }.frame(width: 70, height: 70)
                        .buttonStyle(PinButtonStyle())
                    
                case .done:
                    Button {
                        action?()
                    } label: {
                        Text(item.text)
                            .foregroundColor(self.fieldContent.passwordValidator() ? .white : .white.opacity(0.24) )
                    }.buttonStyle(PinButtonStyle())
                        .frame(width: 70, height: 70)
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
        ContainerView{
            PinView(fieldContent: .constant(""),
                    keyboardNumbers: UnlockKeyboardNumbers)
        }
    }
}

