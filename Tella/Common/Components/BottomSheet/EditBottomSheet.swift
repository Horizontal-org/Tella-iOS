//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct EditBottomSheet: View {
    var titleText = ""
    @State private var filename = ""
    var cancelText = ""
    var actionText = ""
    @Binding var isPresented: Bool
    var didConfirmAction : (String) -> ()
    
    
    struct ButtonSheetStyle: ButtonStyle {
        
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(configuration.isPressed ? Color.red : Color.white)
                .padding(.leading, 20)
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, content: {
            Text(self.titleText)
                .foregroundColor(.white)
                .font(Font.custom("OpenSans-Regular", size: 20))
                .fontWeight(.regular)
                .padding(.top, 20)
                
                .padding(.horizontal, 20)
            VStack{
                TextField("name", text : self.$filename)
                    .foregroundColor(.white)
                    .font(Font.custom("OpenSans-Regular", size: 20))
                Divider()
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                    .background(Color.red)
            }.padding()
            
            
            HStack(alignment: .lastTextBaseline ){
                Spacer()
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.filename = ""
                    
                    self.isPresented = false
                    
                }){
                    Text(self.cancelText)
                }.buttonStyle(ButtonSheetStyle())
                
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.isPresented = false
                    self.didConfirmAction(filename)
                    self.filename = ""
                }){
                    Text(self.actionText)
                }.buttonStyle(ButtonSheetStyle())
                
            }
            .padding(.trailing, 20)
            .padding(.bottom, 40)
            Spacer()
        }) .background(Color("PrimaryColor"))
        .frame(width: UIScreen.main.bounds.size.width)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .frame(width: UIScreen.main.bounds.size.width)
        
    }}



private struct TestEdit: View {
    @State var show = true
    @State var value : CGFloat = 0
    
    var body: some View {
        
        ZStack {
            Button(action: {
                    self.show.toggle()}){
                Text("Action sheet")
            }
            DragView(modalHeight: 220, color: Styles.Colors.backgroundTab, isShown: $show){
                EditBottomSheet(titleText: "Rename file", cancelText: "Cancel", actionText: "Confirm", isPresented: self.$show, didConfirmAction: {
                    name in
                    print(name)
                })
            }
        }
    }
}


struct EditBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        TestEdit()
    }
}
