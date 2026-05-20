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
            ConfirmBottomSheetHeaderView(titleText: titleText, msgText: msgText)
            Spacer()
            buttonsView
        }
    }
    
    @ViewBuilder
    var imageView: some View {
        if let imageName {
            HStack {
                Spacer()
                Image(imageName)
                Spacer()
            }
            .frame(height: 90)
        }
    }
    
    var buttonsView: some View {
        HStack(alignment: .lastTextBaseline ) {
            Spacer()
            
            if let cancelText {
                BottomSheetButton(title: cancelText) {
                    didCancelAction?()
                    if shouldHideSheet {
                        sheetManager.hide()
                    }
                }
            }
            if let discardText = discardText {
                Spacer()
                    .frame(width: 10)
                BottomSheetButton(title: discardText) {
                    didDiscardAction?()
                    if shouldHideSheet {
                        sheetManager.hide()
                    }
                }
            }
            Spacer()
                .frame(width: 10)
            BottomSheetButton(title: actionText, destructive: destructive) {
                didConfirmAction()
                if shouldHideSheet {
                    sheetManager.hide()
                }
            }
        }
    }
}

struct ConfirmBottomSheetHeaderView: View {
    var titleText: String
    var msgText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomText(titleText, style: .heading2Style)
            Spacer()
                .frame(height: 9)
            CustomText(msgText, style: .body1Style)
        }
    }
}

struct BottomSheetButton: View {
    let title: String
    let action: () -> Void
    var destructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .foregroundColor(destructive ? Color.red : Color.white)
        }
        .buttonStyle(ButtonSheetStyle())
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
