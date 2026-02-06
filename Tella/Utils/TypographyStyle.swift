//
//  TypographyStyle.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import UIKit

enum TypographyStyle {  
    
    case heading1Style
    case heading2Style
    case heading3Style
    case subheading1Style
    case subheading2Style
    case body1Style
    case body2Style
    case body2ItalicStyle
    case body3Style
    
    case buttonLStyle
    case buttonSStyle
    case buttonDetailRegularStyle
    case buttonDetailBoldStyle
    
    case link1Style

    var fontSize: CGFloat {
        switch self {
            
        case .heading1Style:
            return  18
        case .heading2Style:
            return 16
        case .heading3Style:
            return 16
        case .subheading1Style:
            return 14
        case .subheading2Style:
            return 10
        case .body1Style:
            return 14
        case .body2Style:
            return 12
        case .body2ItalicStyle:
            return 12
        case .body3Style:
            return 10
        case .buttonLStyle:
            return 16
        case .buttonSStyle:
            return 14
        case .buttonDetailRegularStyle:
            return 11
        case .buttonDetailBoldStyle:
            return 11
        case .link1Style:
            return 16
        }
    }
    
    var name: String {
        switch self {
        case .heading1Style:
            return Styles.Fonts.semiBoldFontName
        case .heading2Style:
            return Styles.Fonts.semiBoldFontName
        case .heading3Style:
            return Styles.Fonts.boldFontName
        case .subheading1Style:
            return Styles.Fonts.semiBoldFontName
        case .subheading2Style:
            return Styles.Fonts.boldFontName
        case .body1Style:
            return Styles.Fonts.regularFontName
        case .body2Style:
            return Styles.Fonts.regularFontName
        case .body2ItalicStyle:
            return Styles.Fonts.italicRobotoFontName
        case .body3Style:
            return Styles.Fonts.regularFontName
        case .buttonLStyle:
            return Styles.Fonts.boldFontName
        case .buttonSStyle:
            return Styles.Fonts.semiBoldFontName
        case .buttonDetailRegularStyle:
            return Styles.Fonts.regularFontName
        case .buttonDetailBoldStyle:
            return Styles.Fonts.regularFontName
        case .link1Style:
            return Styles.Fonts.regularFontName
        }
    }
    
    var characterSpacing: CGFloat {
        switch self {
        case .subheading2Style, .body1Style, .buttonLStyle:
            return 0.5
        case .buttonSStyle:
            return 0.3
        default:
            return 0
        }
    }
    
    var lineHeight: CGFloat {
        
        var lineHeightMultiplier: CGFloat
        
        switch self {
        case .subheading2Style:
            lineHeightMultiplier = 1.23
            
        case .body1Style:
            lineHeightMultiplier = 1.5
            
        default:
            lineHeightMultiplier = 1
            
        }
        return fontSize * lineHeightMultiplier
    }
    
    var lineSpacing: CGFloat {
        return lineHeight - font.lineHeight
    }
    
    var font : UIFont {
        return UIFont(name: name, size: fontSize) ?? .systemFont(ofSize: 12)
    }

}
