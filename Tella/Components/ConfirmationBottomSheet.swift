//
//  ConfirmationBottomSheet.swift
//  Tella
//
//  Created by Gustavo on 16/03/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ConfirmationBottomSheet: View {
    let options: [MainAppModel.ImportOption]
    let headerTitle: String
    let content: String
    let subContent: String
    let action: ((MainAppModel.ImportOption) -> Void)
    
    @State private var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(headerTitle)
                .padding(.bottom, 5)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
            Text(content)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
            Text(subContent)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
            Divider()
            HStack() {
                Spacer()
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option.localizedValue
                        action(option)
                    }, label: {
                        HStack(alignment: .center) {
                            Spacer()
                            Text(option.localizedValue)
                                .foregroundColor(.white)
                                .font(.custom(Styles.Fonts.semiBoldFontName, size: 15))
                        }
                    })
                }
            }
        }
        .padding(EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
