//
//  ImageTitleMessageContent.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

protocol ImageTitleMessageContent: Hashable {
    var imageName: ImageResource? { get }
    var title: String { get }
    var message: String { get }
}
