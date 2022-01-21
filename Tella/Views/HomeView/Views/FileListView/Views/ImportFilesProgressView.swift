//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ImportFilesProgressView: View {
    
    @Binding var showingProgressView : Bool
    @ObservedObject var appModel: MainAppModel
    @State var showingCancelImportConfirmationSheet : Bool = false
    
    var modalHeight : CGFloat = 179
    
    var body: some View {
        
        ZStack{
            DragView(modalHeight: modalHeight,
                     color: Styles.Colors.backgroundTab,
                     isShown: $showingProgressView) {
                ImportFilesProgressContentView
            }
            
            CancelImportView(showingCancelImportConfirmationSheet: $showingCancelImportConfirmationSheet,
                             appModel: appModel) {
                
                appModel.vaultManager.progress.finish()
                
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
                
                Text("\(appModel.vaultManager.progress.progressFile) \(LocalizableHome.importProgressFileImported.localized)")
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 24)
                
                ProgressView("", value: appModel.vaultManager.progress.progress.value, total: 1)
                    .accentColor(.green)
                
                Spacer()
                    .frame(height: 40)
                
                HStack {
                    Spacer()
                    Button("CANCEL") {
//                        showingProgressView = false
                        
                        showingCancelImportConfirmationSheet = true
                        
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 14))
                }
            }
        }
        .padding(EdgeInsets(top: 21, leading: 24, bottom: 30, trailing: 24))
        .onReceive(appModel.vaultManager.progress.progress) { value in
            if value == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    showingProgressView = false
                }
            }
        }
        
    }
}

struct ImportFilesProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ImportFilesProgressView(showingProgressView: .constant(true),
                                appModel: MainAppModel(),
                                showingCancelImportConfirmationSheet: true)
    }
}
