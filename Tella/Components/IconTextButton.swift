//
//  IconTextButton.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

protocol IconTextButtonConfig {
    var title : String { get }
    var description: String { get }
    var imageName: String { get }
}

private struct MockIconTextButtonConfig: IconTextButtonConfig {
    let title: String = "Mock Icon Text Title"
    let description: String = "Mock Icon Text Desription"
    let imageName: String = "lock.fill"
}

struct IconTextButton<Destination:View> : View {
    
    var buttonConfig : IconTextButtonConfig
    var destination : Destination
    var action: (() -> ())?

    var body: some View {
        
        Button {
            if let action {
                action()
            } 

            navigateTo(destination: destination)
        } label: {
            HStack(spacing: 20) {
                
                Image(buttonConfig.imageName)
                    .aspectRatio(contentMode: .fit)
                
                VStack(alignment:.leading, spacing: 3 ) {
                    
                    CustomText(buttonConfig.title,
                               style: .buttonLStyle)
                    
                    CustomText(buttonConfig.description,
                               style: .buttonDetailRegularStyle)
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                
            } .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, 16)
        }
        .buttonStyle(TellaButtonStyle(buttonStyle: ClearButtonStyle(), isValid: true))
    }
}

#Preview {
    IconTextButton(buttonConfig: MockIconTextButtonConfig(),
                   destination: Text("Destination"))
}
