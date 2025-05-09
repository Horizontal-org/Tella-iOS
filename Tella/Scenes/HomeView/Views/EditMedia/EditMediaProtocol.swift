//
//  EditMediaProtocol.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/5/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import UIKit

protocol EditMediaProtocol {
    var leadingImageName: String { get }
    var trailingImageName: String { get }
    var playImageName: String { get }
    var leadingPadding: CGFloat { get }
    var trailingPadding: CGFloat { get }
    var sliderWidth: CGFloat { get }
    var horizontalPadding: CGFloat { get }
    var leadingLabelPadding: CGFloat { get }
    var trailingLabelPadding: CGFloat { get }
    var extraLeadingSpace: CGFloat { get }
    var extraTrailingSpace: CGFloat { get }
}

struct EditVideoParameters : EditMediaProtocol {
    
    var leadingImageName: String = "edit.video.left.icon"
    var trailingImageName: String = "edit.video.right.icon"
    var playImageName: String = "edit.video.play.line"
    var leadingPadding: CGFloat = 0.0
    var leadingLabelPadding: CGFloat = -8
    var trailingLabelPadding: CGFloat = -18
    
    var trailingPadding: CGFloat {
        UIScreen.screenWidth -  2 * horizontalPadding  - sliderWidth
    }
    
    var horizontalPadding: CGFloat {
        return 16
    }
    
    var sliderWidth: CGFloat {
        return 18
    }

    var extraLeadingSpace: CGFloat = 3
    var extraTrailingSpace: CGFloat = 5
}

struct EditAudioParameters : EditMediaProtocol {

    var leadingImageName: String = "edit.audio.trim.line"
    var trailingImageName: String = "edit.audio.trim.line"
    var playImageName: String =  "edit.audio.play.line"
    var leadingPadding: CGFloat = 0.0
    var leadingLabelPadding: CGFloat = -20
    var trailingLabelPadding: CGFloat = -10
    
    var horizontalPadding: CGFloat {
        return 20
    }
    
    var sliderWidth: CGFloat {
        return 10
    }
    
    var trailingPadding: CGFloat {
        UIScreen.screenWidth -  2 * horizontalPadding  - sliderWidth
    }
    
    var extraLeadingSpace: CGFloat = 4
    var extraTrailingSpace: CGFloat = 7
}

enum SliderType {
    case leading
    case trailing
}
