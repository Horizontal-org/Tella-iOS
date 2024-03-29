//
//  NSUIImage.swift
//  Tella
//
//  Created by Ahlem on 30/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
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
