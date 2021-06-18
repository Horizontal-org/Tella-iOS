//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

struct AddFileBottomSheetFileActions: View {
    @Binding var isPresented: Bool
    
    let items = [
        ListActionSheetItem(imageName: "upload-icon", content: "Take photo/video", action: {
        }),
        ListActionSheetItem(imageName: "upload-icon", content: "Record audio", action: {}),
        ListActionSheetItem(imageName: "upload-icon", content: "Import from device", action: {}),
        ListActionSheetItem(imageName: "delete-icon", content: "Import and delete original file", action: {})
    ]
    
    var body: some View {
        ZStack{
            DragView(modalHeight: CGFloat(items.count * 40 + 100), color: Styles.Colors.backgroundTab, isShown: $isPresented){
                ListActionSheet(items: items, headerTitle: "Add file to ...", isPresented: $isPresented)
            }
        }
    }
}
