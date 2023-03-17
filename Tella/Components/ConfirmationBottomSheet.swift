//
//  ConfirmationBottomSheet.swift
//  Tella
//
//  Created by Gustavo on 16/03/2023.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmationBottomSheet: View {
    let options: [String]
    let headerTitle: String
    let content: String
    let action: ((String) -> Void)
    
    @State private var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(headerTitle)
                .padding(.bottom, 10)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
            Text(content)
                .foregroundColor(.white)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
            Divider()
            Spacer()
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                    action(option)
                }, label: {
                    HStack(alignment: .lastTextBaseline) {
                        Text(option)
                            .foregroundColor(.white)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 17))
                        Spacer()
                    }
                })
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 24, bottom: 0, trailing: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
