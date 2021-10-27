//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct PinView: View {
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    @Binding var fieldContent : String
    var keyboardNumbers : [PinKeyboardModel]
    var action : (() -> Void)?
    
    
    var body: some View {
        
        LazyVGrid(columns: columns) {
            
            ForEach(keyboardNumbers, id: \.self) { item in
                switch item.type {
                case .delete:
                    Button {
                        self.delete(pin: item.text)
                    } label: {
                        Image(item.imageName)
                    }.buttonStyle(PinButtonStyle())
                        .disabled(!(self.fieldContent.count>0))
                        .padding(10)

                case .number:
                    Button {
                        self.appendPin(pin: item.text)
                    } label: {
                        Text(item.text)
                    }
                    .padding(10)
                    .buttonStyle(PinButtonStyle())
                case .done:
                    Button {
                        action?()
                    } label: {
                        Text(item.text)
                    }.buttonStyle(PinButtonStyle())
                        .padding(10)

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

