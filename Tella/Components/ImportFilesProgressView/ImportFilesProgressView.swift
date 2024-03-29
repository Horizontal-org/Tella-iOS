//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ImportFilesProgressView: View {
    
    @EnvironmentObject var mainAppModel : MainAppModel
    @EnvironmentObject var sheetManager: SheetManager
    @ObservedObject var progress : ProgressFile
    
    var importFilesProgressProtocol : ImportFilesProgressProtocol
    var modalHeight : CGFloat = 215
    
    var body: some View {
        
        HStack(spacing: 14) {
            VStack{
                Spacer()
                    .frame(height: 22)
                
                Image("home.progress-circle")
                
                Spacer()
            }
            
            VStack(alignment: .leading) {
                
                Text(importFilesProgressProtocol.title)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
                    .foregroundColor(.white)
                Spacer()
                    .frame(height: 10)
                
                if importFilesProgressProtocol.progressType == .number {
                    Text(String.init(format:importFilesProgressProtocol.progressMessage ,  progress.progressFile))
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                    
                } else {
                    Text(String.init(format:importFilesProgressProtocol.progressMessage + " " , Int(progress.progress * 100)))
                    
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
                
                Spacer()
                    .frame(height: 8)
                
                ProgressView("", value: progress.progress, total: 1)
                    .accentColor(.green)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(importFilesProgressProtocol.cancelImportButtonTitle) {
                        showCancelImportView()
                    }
                    .foregroundColor(Color.white)
                    .font(Font.custom(Styles.Fonts.semiBoldFontName, size: 14))
                }
            }
        }
        .padding(EdgeInsets(top: 25, leading: 25, bottom: 35, trailing: 25))
        .onReceive( progress.$isFinishing) { isFinishing in
            if isFinishing {
                sheetManager.hide()
            }
        }
    }
    
    func showCancelImportView() {
        sheetManager.showBottomSheet( modalHeight: 152,
                                      shouldHideOnTap: false,
                                      content: {
            CancelImportView(importFilesProgressProtocol: importFilesProgressProtocol)
        })
    }
}

struct ImportFilesProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ImportFilesProgressView(progress: ProgressFile(),
                                importFilesProgressProtocol: ImportFilesProgress())
        .background(Styles.Colors.backgroundMain)
    }
}
