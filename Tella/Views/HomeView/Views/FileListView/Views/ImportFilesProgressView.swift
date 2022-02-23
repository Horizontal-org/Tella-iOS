//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI


enum ProgressType {
    case percentage
    case number
}

struct ImportFilesProgressView: View {
    
    @Binding var showingProgressView : Bool
    @State var showingCancelImportConfirmationSheet : Bool = false
    @EnvironmentObject var mainAppModel : MainAppModel
    
    var modalHeight : CGFloat = 179
    
    var progressType : ProgressType = .number
    
    
    var body: some View {
        
        ZStack{
            DragView(modalHeight: modalHeight,
                     shouldHideOnTap: false,
                     isShown: $showingProgressView) {
                ImportFilesProgressContentView
            }
            
            CancelImportView(showingCancelImportConfirmationSheet: $showingCancelImportConfirmationSheet, appModel: mainAppModel) {
                mainAppModel.cancelImportAndEncryption()
                mainAppModel.vaultManager.progress.stop()
                showingProgressView = false
                showingCancelImportConfirmationSheet = false
            } didCancel: {
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
                
                Text(LocalizableHome.importProgressTitle.localized)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                    .frame(height: 8)
                
                if progressType == .number {
                    Text("\(mainAppModel.vaultManager.progress.progressFile.value) \(LocalizableHome.importProgressFileImported.localized)")
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                    
                } else {
                    Text("\(Int(mainAppModel.vaultManager.progress.progress.value * 100))% complete  ")
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

struct ImportFilesProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ImportFilesProgressView(showingProgressView: .constant(true),
                                showingCancelImportConfirmationSheet: true)
    }
}
