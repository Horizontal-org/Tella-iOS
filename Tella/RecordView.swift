//
//  RecordView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class will handle the recording functionality of the app. Functionality should allow users to record audio which will automatically be saved and encrypted in the Tella app but not on the users phone
 */
import SwiftUI

struct RecordView: View {
    
    let back: Button<AnyView>
    
    var body: some View {
        return Group {
            bigText("RECORD", false)
            back
        }
    }
}
