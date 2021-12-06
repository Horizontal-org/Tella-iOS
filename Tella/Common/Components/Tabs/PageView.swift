//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

public struct PageView: View {
    
    @Binding var selectedOption: Pages
    @Binding var outboxCount: Int
    let pageWidth = UIScreen.main.bounds.size.width/5
    var titles = ["New","Draft","Outbox","Sent"]
    
   public var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .new
                }
            }, label: {
                PageViewCell(title: titles[0], width: pageWidth, page: .new, selectedOption: $selectedOption)
            })
        
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .draft
                }
            }, label: {
                PageViewCell(title: titles[1], width: pageWidth, page: .draft, selectedOption: $selectedOption)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .outbox
                }
            }, label: {
                PageViewCellNotification(title: titles[2], width: pageWidth, page: .outbox, selectedOption: $selectedOption, outBoxCount: $outboxCount)
            })
            
            Button(action: {
                withAnimation(.interactiveSpring()){
                    self.selectedOption = .sent
                }
            }, label: {
                PageViewCell(title: titles[3], width: pageWidth, page: .sent, selectedOption: $selectedOption)
            })
        }
    }
}
