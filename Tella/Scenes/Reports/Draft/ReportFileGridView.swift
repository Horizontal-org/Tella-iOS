//
//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ReportFileGridView<T: ServerProtocol>: View {
    
    var file: VaultFileDB
    
    @EnvironmentObject var draftReportVM: DraftMainViewModel<T>
    
    var body: some View {
        fileGridView
            .overlay(deleteButton, alignment: .topTrailing)
    }
    
    var fileGridView : some View {
        ZStack {
            file.gridImage
            self.fileNameText
        }
    }
    
    var deleteButton : some View {
        Button {
            draftReportVM.deleteFile(fileId: file.id)
        } label: {
            Image("report.delete")
                .padding(.all, 10)
        }
    }
    
    @ViewBuilder
    var fileNameText: some View {
        
        if self.file.tellaFileType != .image || self.file.tellaFileType != .video {
            VStack {
                Spacer()
                Text(self.file.name)
                    .font(.custom(Styles.Fonts.regularFontName, size: 11))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                    .frame(height: 6)
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}

//
//struct ReportFileGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportFileGridView()
//    }
//}
