//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmBottomSheet : View {
    var titleText = ""
    var msgText = ""
    var cancelText = ""
    var actionText = ""
    var destructive : Bool = false
    var withDrag : Bool = true
    
    var didConfirmAction : () -> ()
    var didCancelAction : (() -> ())? = nil
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        contentView
    }
    
    var contentView: some View {
        
        VStack(alignment: .leading, spacing: 9) {
            
            Text(self.titleText)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 17))
            
            Text(self.msgText)
                .foregroundColor(.white)
                .font(Font.custom(Styles.Fonts.regularFontName, size: 14))
            Spacer()
            HStack(alignment: .lastTextBaseline ){
                Spacer()
                Button(action: {
                    didCancelAction?()
                    sheetManager.hide()
                    
                }){
                    Text(self.cancelText)
                }.buttonStyle(ButtonSheetStyle())
                
                Spacer()
                    .frame(width: 20)
                
                Button(action: {
                    self.didConfirmAction()
                    sheetManager.hide()
                }){
                    Text(self.actionText)
                        .foregroundColor(destructive ? Color.red : Color.white)
                }.buttonStyle(ButtonSheetStyle())
            }
        } .padding(EdgeInsets(top: 28, leading: 24, bottom: 24, trailing: 20))
    }
    
    
}

struct ButtonSheetStyle: ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 14))
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
