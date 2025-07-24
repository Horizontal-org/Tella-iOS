//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct OutboxDetailsItemView: View {
    
    @Binding var item : ProgressFileItemViewModel
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 35, height: 35, alignment: .center)
                .overlay(
                    item.vaultFile.listImage
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                )
            VStack(alignment: .leading, spacing: 0){
                Spacer()
                
                CustomText(item.vaultFile.name,
                           style: .subheading1Style)
                .lineLimit(1)

                Spacer()
                    .frame(height: 2)
                
                CustomText(item.transferSummary,
                           style: .body3Style)

                Spacer()
                
            }
            .padding(EdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 40))
            
            Spacer()

            if let p2pFileStatus = item.p2pFileStatus,
               let statusIcon = p2pFileStatus.statusIcon {
                Image(statusIcon)
            }
        }
    }
}


struct ReportDetailsItemView_Previews: PreviewProvider {
    static var previews: some View {
        OutboxDetailsItemView(item: .constant(ProgressFileItemViewModel(vaultFile: VaultFileDB.stub(), transferSummary: "0/4.5 MB") ))
    }
}
