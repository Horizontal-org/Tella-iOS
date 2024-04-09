//
//  ReloadButton.swift
//  Tella
//
//  Created by gus valbuena on 1/31/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ReloadButton: ToolbarContent {
 var action: () -> Void
 var body: some ToolbarContent {
     ToolbarItem(placement: .navigationBarTrailing) {
         Button(action: action) {
             Image("arrow.clockwise")
                 .resizable()
                 .frame(width: 24, height: 24)
         }
     }
 }
}
