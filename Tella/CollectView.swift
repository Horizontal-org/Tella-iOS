//
//  CollectView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class is for the Collect button. This functionality should allow users to respond to forms from non-profit third parties. They can complete surveys and submit data to third party servers.
 */
import SwiftUI

struct CollectView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        Group {
            bigText("COLLECT", false)
            BackButton {
                self.appViewState.navigateBack()
            }
        }
    }
}
