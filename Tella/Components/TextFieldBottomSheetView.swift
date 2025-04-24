//
//  CreateNewFolderBottomSheet.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine



struct TextFieldBottomSheetView: View {
    
    var titleText = ""
    var validateButtonText = ""
    var cancelButtonText = ""

    @Binding var fieldContent : String
    
    var fileName : String = ""
    var didConfirmAction : (() -> ())
    
    @State private var isValid : Bool = false
    @State private var errorMessage : String = ""
    
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text(titleText)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
            Spacer()
                .frame(height:12)
            
            if #available(iOS 15.0, *) {
                
                FocusedTextFieldBottomSheet(fieldContent: $fieldContent,
                                            isValid: $isValid)
                
            } else {
                TextFieldBottomSheet(fieldContent: $fieldContent,
                                     isValid: $isValid)
            }
            
            Spacer()
                .frame(height:8)
            
            Divider()
                .frame(height: 2)
                .background(Styles.Colors.yellow)
            Spacer()
                .frame(height:4)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(Styles.Colors.yellow)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                BottomButtonActionSheetView(title: cancelButtonText, shouldEnable: true) {
                    fieldContent = ""
                    sheetManager.hide()
                }
                
                BottomButtonActionSheetView(title: validateButtonText, shouldEnable: self.isValid) {
                    
//                    if fieldContent == fileName {
//                        errorMessage = Localizable.Common.sameFileNameError
//                    } else {
                        didConfirmAction()
                        fieldContent = ""
//                    }
                    sheetManager.hide()
                }
            }
        }.padding(EdgeInsets(top: 21, leading: 24, bottom: 0, trailing: 21))
    }
}

@available(iOS 15.0, *)
struct FocusedTextFieldBottomSheet : View {
    
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    
    @FocusState private var isFocused : Bool
    
    var body: some View {
        ZStack{
            TextField("", text: $fieldContent)
                .textFieldStyle(FileNameStyle())
                .onChange(of: fieldContent, perform: { value in
                    self.isValid = fieldContent.textValidator()
                })
                .focused($isFocused)
        }
        .onAppear {
            isFocused = true
        }
    }
}

struct TextFieldBottomSheet : View {
    
    @Binding var fieldContent : String
    @Binding var isValid : Bool
    
    var body: some View {
        
        TextField("", text: $fieldContent)
            .textFieldStyle(FileNameStyle())
            .onChange(of: fieldContent, perform: { value in
                self.isValid = fieldContent.textValidator()
            })
    }
}

struct FileNameStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
            .accentColor(Styles.Colors.yellow)
            .multilineTextAlignment(.leading)
            .disableAutocorrection(true)
            .keyboardType(.alphabet)
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

struct CreateNewFolderBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldBottomSheetView(titleText: "Test",
                                 validateButtonText: "OK",
                                 fieldContent: .constant("Test"),
                                 fileName: "name",
                                 didConfirmAction: {})
    }
}
