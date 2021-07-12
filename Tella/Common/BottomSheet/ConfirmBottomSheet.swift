//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmBottomSheet : View {
    var titleText = ""
    var msgText = ""
    var cancelText = ""
    var actionText = ""
    @Binding var isPresented: Bool
    var didConfirmAction : () -> ()
    var body: some View {
        
        VStack(alignment: .leading, content: {
            Spacer()
            Text(self.titleText)
                .foregroundColor(.white)
                .font(Font.custom("open-sans.regular", size: 20))
                .fontWeight(.regular)
                .padding(.top, 20)
                .padding(.horizontal, 20)
            
            Text(self.msgText)
                .foregroundColor(.white)
                .font(Font.custom("open-sans.regular", size: 14))
                .fontWeight(.light)
                .padding(20)
            
            HStack(alignment: .lastTextBaseline ){
                Spacer()
                Button(action: {self.isPresented = false}){
                    Text(self.cancelText)
                }.buttonStyle(ButtonSheetStyle())
                
                Button(action: {self.didConfirmAction()}){
                    Text(self.actionText)
                }.buttonStyle(ButtonSheetStyle())
                
            }
            .padding(.trailing, 20)
            .padding(.bottom, 40)
        })
        .background(Color("PrimaryColor"))
        .cornerRadius(25)
    }
}

struct ButtonSheetStyle: ButtonStyle {

  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .foregroundColor(configuration.isPressed ? Color.red : Color.white)
      .padding(.leading, 20)
  }
}

private struct TestView: View {
    @State var show = true
    
    var body: some View {
        
        ZStack {
            Button(action: {
                    self.show.toggle()}){
                Text("Action sheet")
            }
            DragView(modalHeight: 220, color: Styles.Colors.backgroundTab, isShown: $show){
                ConfirmBottomSheet(titleText: "Delete file?", msgText: "The selected file will be permanenetly delated from your vault.",cancelText: "CANCEL",actionText: "DELETE",isPresented: $show,didConfirmAction: {})
            }
        }
    }
}

struct ConfirmBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
