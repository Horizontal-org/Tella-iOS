//
//  NSUIImage.swift
//  Tella
//
//  Created by Ahlem on 30/06/2021.
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import UIKit
import SwiftUI

public typealias NSUIImage = UIImage

extension NSUIImage {
  var dataImage: Data? {
    return self.pngData()
  }

  static func image(fromData data: Data) -> Image {
    return Image(uiImage: UIImage(data: data) ?? UIImage())
  }
}
