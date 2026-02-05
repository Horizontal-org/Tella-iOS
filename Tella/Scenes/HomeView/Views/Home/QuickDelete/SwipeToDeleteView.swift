//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import UIKit

struct SwipeToDeleteActionView: View {
    
    let completion: (() -> ())?
    
    private let height: CGFloat = 50
    private let maxtTranslationWidth: CGFloat = UIScreen.main.bounds.width - 90
    private let width: CGFloat = UIScreen.main.bounds.width - 40
    
    @State private var offset:CGFloat = 0
    
    private var isRTL: Bool {
        LanguageManager.shared.currentLanguage.isRTL
    }
    
    private func calculateOffset(from translation: CGFloat) -> CGFloat {
        if isRTL {
            if translation < 0 {
                let absTranslation = abs(translation)
                if absTranslation >= maxtTranslationWidth {
                    return maxtTranslationWidth
                } else {
                    return -translation
                }
            } else {
                return 0
            }
        } else {
            if translation > 0 {
                if translation >= maxtTranslationWidth {
                    return maxtTranslationWidth
                } else {
                    return translation
                }
            } else {
                return 0
            }
        }
    }
    
    private func handleSwipeEnd(translation: CGFloat) {
        swipeEndAction()
        
        if isRTL {
            if translation < 0 {
                let absTranslation = abs(translation)
                if absTranslation >= maxtTranslationWidth {
                    showQuickDeleteView()
                }
            }
        } else {
            if translation > 0 {
                if translation >= maxtTranslationWidth {
                    showQuickDeleteView()
                }
            }
        }
    }
    
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
                            self.offset = calculateOffset(from: value.translation.width)
                        })
                        .onEnded({ value in
                            handleSwipeEnd(translation: value.translation.width)
                        }))
                .animation(.linear)
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
        Image(.arrowRight)
            .scaleEffect(x: isRTL ? -1 : 1, y: 1)
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
