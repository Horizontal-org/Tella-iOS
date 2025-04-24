//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import SwiftUI
import UIKit

struct SwipeToDeleteActionView: View {
    
    let completion: (() -> ())?
    
    private let height: CGFloat = 50
    private let maxtTranslationWidth: CGFloat = UIScreen.main.bounds.width - 90
    private let width: CGFloat = UIScreen.main.bounds.width - 40
    
    @State private var offset:CGFloat = 0
    
    //TODO: add DELETE label
    var body: some View {
        ZStack {
            Text(LocalizableHome.quickDeleteSwipeTitle.localized)
                .font(Font.system(size: 16))
                .bold()
                .foregroundColor(Color.white)
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white, lineWidth: 2)
                .frame(width: width, height: height, alignment: .center)
            swipeButton
                .offset(x:offset)
                .frame(width: width - 5, height: height, alignment: .leading)
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            if value.translation.width > 0 {
                                if (value.translation.width >= maxtTranslationWidth) {
                                    self.offset = maxtTranslationWidth
                                }else {
                                    self.offset = value.translation.width
                                }
                            }else {
                                self.offset = 0
                            }
                        })
                        .onEnded({ value in
                            swipeEndAction()
                            if value.translation.width > 0 {
                                if (value.translation.width >= maxtTranslationWidth) {
                                    self.offset = maxtTranslationWidth
                                    swipeEndAction()
                                    showQuickDeleteView()
                                }else {
                                    swipeEndAction()
                                }
                            }else {
                                swipeEndAction()
                            }
                        })).animation(.linear)
        }
        .padding(EdgeInsets(top: 5, leading: 19, bottom: 19, trailing: 19))
    }
    
    func showQuickDeleteView() {
        self.present(style: .overCurrentContext, transitionStyle: .crossDissolve, builder: {QuickDeleteView(completion: completion)})
    }

    func swipeEndAction() {
        offset = 0
    }
    
    var swipeButton: some View {
        Image("arrow-right")
            .frame(width: 45, height: 45, alignment: .center)
            .padding(.zero)
            .background(Color.white.opacity(0.4))
            .cornerRadius(25)
    }
}

struct buttonUI_Previews: PreviewProvider {
    static var previews: some View {
        SwipeToDeleteActionView(completion: nil)
            .background(Color.blue)
    }
}
