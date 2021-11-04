//
//  ViewExtension.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    func navigateTo<Destination: View>( destination: Destination) ->  some View   {
        return  NavigationLink(destination: destination) {
            self
        }
    }
}

