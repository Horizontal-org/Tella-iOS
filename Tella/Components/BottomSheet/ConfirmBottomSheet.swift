//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ConfirmBottomSheet : View {
    var imageName : String? = nil
    var titleText = ""
    var msgText = ""
    var cancelText : String?
    var discardText : String?
    var actionText = ""
    var destructive : Bool = false
    var shouldHideSheet : Bool = true
    
    var didConfirmAction : () -> ()
    var didDiscardAction :(() -> ())? = nil
    var didCancelAction : (() -> ())? = nil
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        VStack(alignment: .leading) {
            
            imageView
            
            CustomText(self.titleText,
                       style: .heading2Style)
            Spacer()
                .frame(height: 9)
            
            CustomText(self.msgText,
                       style: .body1Style)
            Spacer()
            
            buttonsView
            
        } .padding(EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24))
        
    }
    
    @ViewBuilder
    var imageView: some View {
        if let imageName = imageName {
            HStack() {
                Spacer()
                Image(imageName)
                Spacer()
            }.frame(height: 90)
        }
    }
    
    var buttonsView: some View {
        HStack(alignment: .lastTextBaseline ){
            Spacer()
            
            if let cancelText {
                
                Button(action: {
                    didCancelAction?()
                    if shouldHideSheet {
                        sheetManager.hide()
                    }
                    
                }){
                    Text(cancelText)
                }.buttonStyle(ButtonSheetStyle())
            }
            if let discardText = discardText {
                Spacer()
                    .frame(width: 10)
                
                Button(action: {
                    didDiscardAction?()
                    if shouldHideSheet {
                        sheetManager.hide()
                    }
                    
                }){
                    Text(discardText)
                }.buttonStyle(ButtonSheetStyle())
                
            }
            Spacer()
                .frame(width: 10)
            
            Button(action: {
                self.didConfirmAction()
                if shouldHideSheet {
                    sheetManager.hide()
                }
            }){
                Text(self.actionText.uppercased())
                    .foregroundColor(destructive ? Color.red : Color.white)
            }.buttonStyle(ButtonSheetStyle())
        }
    }
}

struct ButtonSheetStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.white.opacity(0.3) : Color.white)
            .style(.buttonSStyle)
            .padding()
    }
}

struct ConfirmBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmBottomSheet(titleText: "Test",
                           msgText: "Test",
                           cancelText: "Test",
                           actionText: "Test",
                           destructive: true,
                           didConfirmAction: {})
    }
}
