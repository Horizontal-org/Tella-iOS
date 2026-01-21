//
//  PinView.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
                            .frame(width: 70, height: 70)
                    }
                    .disabled(!(self.fieldContent.count>0))
                    .buttonStyle(PinButtonStyle(enabled: self.fieldContent.count>0))
                    
                case .number:
                    Button {
                        self.appendPin(pin: item.text)
                    } label: {
                        Text(item.text)
                            .frame(width: 70, height: 70)
                    }
                    .buttonStyle(PinButtonStyle(enabled: true))
                    
                case .done:
                    Button {
                        action?()
                    } label: {
                        Text(item.text)
                            .frame(width: 70, height: 70)
                    }.buttonStyle(PinButtonStyle(enabled: self.fieldContent.passwordValidator()))
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
    
    var enabled : Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.custom(Styles.Fonts.lightRobotoFontName, size: 32))
            .foregroundColor(configuration.isPressed || !enabled ? .white.opacity(0.24) : .white)
            .background(configuration.isPressed ? Color.white.opacity(0.24) : Color.clear)
            .clipShape(Circle())
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView{
            PinView(fieldContent: .constant(""),
                    keyboardNumbers: LockViewModel(lockFlow: .new, appViewState: AppViewState()).unlockKeyboardNumbers)
        }
    }
}

