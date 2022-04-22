//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SaveAudioConfirmationView: View {
    
    @Binding var showingSaveAudioConfirmationView : Bool

    let didConfirm : (() -> Void)?
    let didCancel : (() -> Void)?
    
    let modalHeight = 173.0

    var body: some View {
 
        ConfirmBottomSheet(titleText: Localizable.Audio.saveRecordingTitle,
                           msgText: Localizable.Audio.saveRecordingMessage,
                               cancelText: "Discard",
                               actionText: "Save",
                               modalHeight: modalHeight,
                               withDrag: false,
                               isPresented: $showingSaveAudioConfirmationView) {
                showingSaveAudioConfirmationView = false
                didConfirm?()
                
            } didCancelAction: {
                showingSaveAudioConfirmationView = false
                didCancel?()
            }
        }
 }

struct SaveAudioConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        SaveAudioConfirmationView(showingSaveAudioConfirmationView: .constant(true),
                                  didConfirm: nil,
                                  didCancel: nil)
    }
}
