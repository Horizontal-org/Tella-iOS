//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct SubmittedDetailsItemView: View {
    
    @Binding var item : ProgressFileItemViewModel
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 35, height: 35, alignment: .center)
                .overlay(
                    item.file.listImage
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                )
            VStack(alignment: .leading, spacing: 0){
                Spacer()
                Text(item.file.name)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                
                Spacer()
                    .frame(height: 2)
                
                Text(item.transferSummary)
                    .font(.custom(Styles.Fonts.regularFontName, size: 10))
                    .foregroundColor(Color.white)
                
                Spacer()
                
            }
            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 40))
            
            Spacer()
            
            Image("report.submitted")
            
        }    }
}


struct SubmittedDetailsItemView_Previews: PreviewProvider {
    static var previews: some View {
        OutboxDetailsItemView(item: .constant(ProgressFileItemViewModel(file: VaultFileDB.stub(), transferSummary: "4.5/4.5 MB") ))
    }
}
