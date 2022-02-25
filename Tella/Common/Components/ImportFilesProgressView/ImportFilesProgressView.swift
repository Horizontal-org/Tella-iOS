//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ImportFilesProgressView: View {
    
    @Binding var showingProgressView : Bool
    @State var showingCancelImportConfirmationSheet : Bool = false
    @EnvironmentObject var mainAppModel : MainAppModel
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    
    var modalHeight : CGFloat = 179
    
    var body: some View {
        
        ZStack{
            DragView(modalHeight: modalHeight,
                     shouldHideOnTap: false,
                     showWithAnimation: false,
                     isShown: $showingProgressView) {
                ImportFilesProgressContentView
            }
            
            CancelImportView(showingCancelImportConfirmationSheet: $showingCancelImportConfirmationSheet,
                             appModel: mainAppModel,
                             importFilesProgressProtocol: importFilesProgressProtocol) {
                
                mainAppModel.vaultManager.progress.resume()
                mainAppModel.cancelImportAndEncryption()
                
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
                
                Text(importFilesProgressProtocol.title)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                    .frame(height: 8)
                
                if importFilesProgressProtocol.progressType == .number {
                    Text(String.init(format:importFilesProgressProtocol.progressMessage ,  mainAppModel.vaultManager.progress.progressFile.value))
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                    
                } else {
                    Text(String.init(format:importFilesProgressProtocol.progressMessage + " " , Int(mainAppModel.vaultManager.progress.progress.value * 100)))
                    
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
                
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
        .onReceive(mainAppModel.vaultManager.progress.isFinishing) { isFinishing in
            if isFinishing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    showingProgressView = false
                    showingCancelImportConfirmationSheet = false
                }
            }
        }
    }
}

struct ImportFilesProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ImportFilesProgressView(showingProgressView: .constant(true),
                                showingCancelImportConfirmationSheet: true,
                                importFilesProgressProtocol: ImportFilesProgress())
    }
}
