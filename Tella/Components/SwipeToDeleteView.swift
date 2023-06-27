//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SwipeToActionView: View {

    let completion: (() -> ())?

    private let height: CGFloat = 50
    private let maxtTranslationWidth: CGFloat = UIScreen.main.bounds.width - 40 - 50
    private let width: CGFloat = UIScreen.main.bounds.width - 40

    @State private var offset:CGFloat = 0
    
    // countdown
    @State private var isCountdownActive: Bool = false
    @State private var timeRemaining: Int = 5

    
    //TODO: add DELETE label
    var body: some View {
        return ZStack {
            if isCountdownActive {
                VStack {
                    Text(LocalizableHome.quickDeleteActionTitle.localized)
                        .foregroundColor(.white)
                        .padding(.bottom, 60)
                        .padding(.horizontal, 20)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 35))
                        .multilineTextAlignment(.center)
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .shadow(color: .white, radius: 10)
                        .frame(width: 200, height: 200)
                        .overlay(
                            Text("\(timeRemaining)")
                                .font(.system(size: 120))
                                    .foregroundColor(.white)
                                    )
                                    .padding(.bottom, 80)
                    Text(LocalizableHome.quickDeleteActionCancel.localized)
                        .foregroundColor(.white)
                        .font(.custom(Styles.Fonts.regularFontName, size: 24))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.cancelCountdown()
                }
                .zIndex(99)
                .padding(.top, 250)
            } else {
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
                                if value.translation.width > 0 {
                                    if (value.translation.width >= maxtTranslationWidth) {
                                        self.offset = maxtTranslationWidth
                                        swipeEndAction()
                                        startCountdown()
                                    }else {
                                        self.offset = 0
                                    }
                                }else {
                                    self.offset = 0
                                }
                })).animation(.linear)
            }
        }
        .padding(EdgeInsets(top: 5, leading: 19, bottom: 19, trailing: 19))
    }
    
    func startCountdown() {
            isCountdownActive = true
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                if !isCountdownActive {
                    timer.invalidate()
                    cancelCountdown()
                }
                if (timeRemaining > 0 && isCountdownActive) {
                    timeRemaining -= 1
                }
                if(timeRemaining == 0) {
                    timer.invalidate()
                    cancelCountdown()
                    completion?()
                }
            }
        }
        
    func cancelCountdown() {
        isCountdownActive = false
        timeRemaining = 5
    }
    
    func swipeEndAction() {
        offset = 0
        isCountdownActive = true
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
        SwipeToActionView(completion: nil)
            .background(Color.blue)
    }
}
