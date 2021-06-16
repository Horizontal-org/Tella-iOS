//
//  FormsModel.swift
//  Tella
//
//  Created by Ahlem on 16/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct FormsModel : Identifiable {
    var id = UUID()
    var title: String = ""
    var description: String = ""
    @State var isFavorite: Bool 
}
