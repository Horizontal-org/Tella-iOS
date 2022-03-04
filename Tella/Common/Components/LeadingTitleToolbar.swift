//
//  LeadingTitleToolbar.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LeadingTitleToolbar: ToolbarContent {
    
    var title : String = ""
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Text(title)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 20))
            .foregroundColor(Color.white)
            .frame(width: 260,height:25,alignment:.leading)
        }
    }
 }
