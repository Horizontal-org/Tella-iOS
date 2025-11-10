//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SaveAudioConfirmationView: View {
    
    @ObservedObject var viewModel : RecordViewModel
    @Binding var showingSaveSuccessView : Bool
    
    @EnvironmentObject var sheetManager: SheetManager
    var mainAppModel : MainAppModel

    var body: some View {
        
        ConfirmBottomSheet(titleText: LocalizableRecorder.saveRecordingSheetTitle.localized,
                           msgText: LocalizableRecorder.saveRecordingSheetExpl.localized,
                           cancelText: LocalizableRecorder.saveRecordingCancelSheetAction.localized,
                           discardText: LocalizableRecorder.saveRecordingDiscardSheetAction .localized,
                           actionText: LocalizableRecorder.saveRecordingSaveSheetAction.localized,
                           withDrag: false) {
            
            sheetManager.hide()
            
            self.viewModel.onStopRecording()
            
            DispatchQueue.main.async {
                showingSaveSuccessView = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showingSaveSuccessView = false
            }
            
            
            
            switch self.viewModel.sourceView {
            case .addReportFile:
                viewModel.showingRecoredrView.wrappedValue = false
            default:
                mainAppModel.selectedTab = .home
            }

        } didDiscardAction: {
            switch self.viewModel.sourceView {
            case .addReportFile:
                viewModel.showingRecoredrView.wrappedValue = false
            default:
                sheetManager.hide()
                self.viewModel.onDiscardRecording()
                mainAppModel.selectedTab = .home

            }
        } didCancelAction: {
            sheetManager.hide()
        }
    }
}

struct SaveAudioConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        SaveAudioConfirmationView(viewModel: RecordViewModel(mainAppModel: MainAppModel.stub(),
                                                             rootFile: VaultFileDB.stub(),
                                                             resultFile: .constant([VaultFileDB.stub()]),
                                                             sourceView: .tab,
                                                             showingRecoredrView: .constant(true)),
                                  showingSaveSuccessView: .constant(true),
                                  mainAppModel: MainAppModel.stub())
    }
}
