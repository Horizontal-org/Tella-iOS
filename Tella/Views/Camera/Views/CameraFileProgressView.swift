//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CameraFileProgressView: View {
    
    @Binding var showingProgressView : Bool
    @State var showingCancelImportConfirmationSheet : Bool = false
    @EnvironmentObject var mainAppModel : MainAppModel
    
    @State var progresssss : Double = 0.0
    
    var modalHeight : CGFloat = 180
    
    var progressType : ProgressType = .number
    
    
    var body: some View {
        
        ZStack{
            DragView(modalHeight: modalHeight,
                     shouldHideOnTap: false,
                     isShown: $showingProgressView) {
                ImportFilesProgressContentView
            }
            
            CancelCapturedFileView(showingCancelImportConfirmationSheet: $showingCancelImportConfirmationSheet, appModel: mainAppModel) {
                
                mainAppModel.cancelImportAndEncryption()
                mainAppModel.vaultManager.progress.resume()
                
                showingCancelImportConfirmationSheet = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    mainAppModel.vaultManager.progress.stop()
                    
                    showingProgressView = false
                })
                
            } didCancel: {
                mainAppModel.vaultManager.progress.resume()
                showingCancelImportConfirmationSheet = false
            }
        }
    }
    
    var ImportFilesProgressContentView : some View {
        
        HStack(spacing: 14) {
            VStack{
                Spacer()
                    .frame(height: 22)
                
                Image("home.progress-circle")
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                
                Text(LocalizableCamera.cancelAddFileTitle.localized)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                    .frame(height: 8)
                
                Text("\(Int(mainAppModel.vaultManager.progress.progress.value * 100))% \(LocalizableCamera.addFileProgressComplete.localized) ")
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 24)
                
                ProgressView("", value: mainAppModel.vaultManager.progress.progress.value, total: 1)
                    .accentColor(.green)
                
                Spacer()
                    .frame(height: 40)
                
                HStack {
                    Spacer()
                    Button("CANCEL") {
                        mainAppModel.vaultManager.progress.pause()
                        showingCancelImportConfirmationSheet = true
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 14))
                }
            }
        }
        .padding(EdgeInsets(top: 21, leading: 24, bottom: 30, trailing: 24))
        .onReceive(mainAppModel.vaultManager.progress.progress) { value in
            if value == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingProgressView = false
                }
            }
        }
    }
}


struct CameraFileProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CameraFileProgressView(showingProgressView: .constant(true))
    }
}
