//
//  OnboardingPageView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct ImageTitleMessageView: View {
    
    let content: any ImageTitleMessageContent
    
    var body: some View {
        
        VStack(alignment: .center, spacing: .normal) {
            
            if let imageName = content.imageName {
                Image(imageName)
            }
            
            CustomText(content.title,
                       style: .heading1Style,
                       alignment: .center)
            
            CustomText(content.message,
                       style: .body1Style,
                       alignment: .center)
        }.frame(maxWidth: .infinity)
    }
}

#Preview {
    ImageTitleMessageView(content: RecordContent())
        .background(Color.blue)
}
