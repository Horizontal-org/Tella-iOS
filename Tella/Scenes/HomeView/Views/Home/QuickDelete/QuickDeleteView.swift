//
//  QuickDeleteView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 17/12/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct QuickDeleteView: View {
    
    let completion: (() -> ())?
    
    // Countdown
    @State private var isCountdownActive: Bool = false
    @State private var timeRemaining: Int = 5
    
    //TODO: add DELETE label
    var body: some View {
        ContainerView {
            
            VStack(alignment: .center) {
                Spacer()
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
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
            
            .zIndex(99)
            .onAppear {
                startCountdown()
            }
        }.onTapGesture {
            self.cancelCountdown()
        }
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
                self.dismiss()
            }
        }
    }
    
    func cancelCountdown() {
        isCountdownActive = false
        timeRemaining = 5
        self.dismiss()
    }
}

#Preview {
    QuickDeleteView {
        
    }
}

