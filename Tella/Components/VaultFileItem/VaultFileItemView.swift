//
//  VaultFileItemView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/5/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct VaultFileItemView: View {
    
    var file : VaultFileItemViewModel
    
    var body: some View {
        
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 35, height: 35, alignment: .center)
                .overlay(
                    file.image
                        .frame(width: 35, height: 35)
                        .cornerRadius(5)
                )
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                
                Spacer()
                    .frame(height: 2)
                
                Text(file.size)
                    .font(.custom(Styles.Fonts.regularFontName, size: 10))
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 17)
            
            Spacer()
            
            if let iconName = file.iconName  {
                Image(iconName)
            }
        }
    }
}


