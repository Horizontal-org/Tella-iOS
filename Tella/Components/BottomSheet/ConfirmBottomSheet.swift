//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmBottomSheet : View {
    var imageName : String? = nil
    var titleText = ""
    var msgText = ""
    var cancelText = ""
    var discardText : String?
    var actionText = ""
    var destructive : Bool = false
    var withDrag : Bool = true
    var shouldHideSheet : Bool = true
    
    var didConfirmAction : () -> ()
    var didDiscardAction :(() -> ())? = nil
    var didCancelAction : (() -> ())? = nil
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        VStack(alignment: .leading, spacing: 9) {
            
            if let imageName = imageName {
                HStack() {
                    Spacer()
                    Image(imageName)
                    Spacer()
                }.frame(height: 90)
            }
            
            Text(self.titleText)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 17))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Text(self.msgText)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.regularFontName, size: 14))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            HStack(alignment: .lastTextBaseline ){
                Spacer()
                Button(action: {
                    didCancelAction?()
                    if shouldHideSheet {
                        sheetManager.hide()
                    }
                    
                }){
                    Text(self.cancelText)
                }.buttonStyle(ButtonSheetStyle())
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
        } .padding(EdgeInsets(top: 28, leading: 24, bottom: 24, trailing: 10))
    }
    
    
}

struct ButtonSheetStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.white.opacity(0.3) : Color.white)
            .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 14))
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
