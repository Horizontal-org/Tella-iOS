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
 
        ConfirmBottomSheet(titleText: LocalizableAudio.saveRecordingTitle.localized,
                           msgText: LocalizableAudio.saveRecordingMessage.localized,
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
