//
//  RoundedCorner.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 13/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  func path(in rect: CGRect) -> Path {
      Path(
          UIBezierPath(
              roundedRect: rect,
              byRoundingCorners: corners,
              cornerRadii: CGSize(width: radius, height: radius)
          ).cgPath
      )
  }
}
