//
//  TypographyStyle.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/4/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import UIKit

enum TypographyStyle {  
    
    case heading1Font
    case heading2Font
    case heading3Font
    case subheading1Font
    case subheading2Font
    case body1Font
    case body2Font
    case body3Font
    
    case buttonLStyle
    case buttonSStyle
    case buttonDetailRegularStyle
    case buttonDetailBoldStyle
    
    case link1Style

    var fontSize: CGFloat {
        switch self {
            
        case .heading1Font:
            return  18
        case .heading2Font:
            return 16
        case .heading3Font:
            return 16
        case .subheading1Font:
            return 14
        case .subheading2Font:
            return 10
        case .body1Font:
            return 14
        case .body2Font:
            return 12
        case .body3Font:
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
        case .heading1Font:
            return Styles.Fonts.semiBoldFontName
        case .heading2Font:
            return Styles.Fonts.semiBoldFontName
        case .heading3Font:
            return Styles.Fonts.boldFontName
        case .subheading1Font:
            return Styles.Fonts.semiBoldFontName
        case .subheading2Font:
            return Styles.Fonts.boldFontName
        case .body1Font:
            return Styles.Fonts.regularFontName
        case .body2Font:
            return Styles.Fonts.regularFontName
        case .body3Font:
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
        case .subheading2Font, .body1Font, .buttonLStyle:
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
        case .subheading2Font:
            lineHeightMultiplier = 1.23
            
        case .body1Font:
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
