//
//  TrailingImageButtonToolBar.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct TrailingImageButtonToolBar: ToolbarContent {
    
    var imageName : String = ""
    var completion : (() -> ())?
    
    var body: some ToolbarContent {
       
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                completion?()
            } label: {
                Image(imageName)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .padding()
            }
        }
    }
 }

struct TrailingImageButtonToolBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        } .toolbar {
            TrailingImageButtonToolBar(imageName: "delete-icon-bin")
        }
    }
}
