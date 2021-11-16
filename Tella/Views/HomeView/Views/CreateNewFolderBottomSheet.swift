//
//  CreateNewFolderBottomSheet.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CreateNewFolderBottomSheet: View {
    
    @Binding var isPresented: Bool
    
    @ObservedObject var appModel: MainAppModel
    var parent : VaultFile?
    @State private var fieldContent : String = ""
    @State private var isValid : Bool = false
    
    var body: some View {
        ZStack{
            DragView(modalHeight: 165,
                     color: Styles.Colors.backgroundTab,
                     isShown: $isPresented) {
                CreateNewFolderContentView
            }
        }
    }

    var CreateNewFolderContentView : some View {
        
        VStack(alignment: .leading, spacing: 15) {
            Text("New folder title")
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.boldFontName, size: 16))
                .padding(EdgeInsets(top: 21, leading: 24, bottom: 0, trailing: 24))
            
            
            VStack(spacing: 8) {
                TextField("", text: $fieldContent)
                    .textFieldStyle(FileNameStyle())
                    .onChange(of: fieldContent, perform: { value in
                        self.isValid = value.textValidator()
                    })
                Divider()
                    .frame(height: 2)
                    .background(Styles.Colors.buttonAdd)
                
            }.padding(EdgeInsets(top: 0, leading: 24, bottom: 13, trailing: 24))
            
            HStack {
                Spacer()
                
                BottomButtonActionSheetView(title: "CANCEL",
                                            shouldEnable: true) {
                    isPresented = false
                    fieldContent = ""
                }
                
                BottomButtonActionSheetView(title: "OK",
                                            shouldEnable: self.isValid) {
                    isPresented = false
                    appModel.add(folder: fieldContent , to: parent)
                    fieldContent = ""
                }
            }
        }
    }
}

struct FileNameStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 18))
            .foregroundColor(Color.white)
            .accentColor(Styles.Colors.buttonAdd)
            .multilineTextAlignment(.leading)
            .disableAutocorrection(true)
            .textContentType(UITextContentType.oneTimeCode)
    }
}

struct BottomButtonActionSheetView : View  {
    
    var title : String
    var shouldEnable : Bool
    var action: (() -> Void)
    
    var body: some View {
        
        Button(title) {
            UIApplication.shared.endEditing()
            action()
        }
        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
        .foregroundColor(shouldEnable ? Color.white : Color.gray)
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 21, trailing: 21))
        .disabled(!shouldEnable)
    }
}




//struct CreateNewFolderBottomSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateNewFolderBottomSheet()
//    }
//}
