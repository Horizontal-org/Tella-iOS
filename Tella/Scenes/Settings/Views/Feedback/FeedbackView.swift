//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    
    @StateObject var feedbackViewModel : FeedbackViewModel
    @State var showSaveDraftSheet : Bool = false
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager

    init(mainAppModel:MainAppModel) {
        _feedbackViewModel = StateObject(wrappedValue: FeedbackViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        ContainerView {
            content
        }.onReceive(feedbackViewModel.$feedbackSentSuccessfully) { _ in
            handleFeedbackSentSuccessfully()
        }.onReceive(feedbackViewModel.$showErrorToast) { _ in
            handleErrorToast()

        }
    }

    var content : some View {
        
        ZStack {
            
            feedbackContentView
            
            submitButton
            
            confirmBottomSheet

            if feedbackViewModel.showOfflineToast {
                OfflineFeedbackToast()
            }
            
            if  feedbackViewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
    }
    
    var feedbackContentView: some View {
        VStack() {
            
            VStack(spacing: 24) {
                
                CloseHeaderView(title: LocalizableSettings.settFeedbackAppBar.localized) {
                    showSaveFeedbackConfirmationView()
                }
                
                introductionView
                
                dividerView
                
                manageFeedbackView
                
                feedbackTextView
            }
            
            Spacer()
        }
        
    }
    
    var introductionView : some View {
        
        CardFrameView {
            HStack(spacing: 0) {
                
                Image("settings.share-data")
                
                Spacer().frame(width: 24)
                
                Text(LocalizableSettings.settFeedbackExpl.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .foregroundColor(.white)
                
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 18))
        }
    }
    
    var dividerView: some View {
        Divider()
            .frame(height: 0.3)
            .background(Color.white.opacity(0.2))
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    var manageFeedbackView : some View {
        CardFrameView {
            SettingToggleItem(title: LocalizableSettings.enableFeedbackTitle.localized,
                              description: LocalizableSettings.enableFeedbackExpl.localized ,
                              toggle: $appModel.settings.shareFeedback) {
                feedbackViewModel.deleteCurrentDraft()
            }
        }
    }

    @ViewBuilder
    var feedbackTextView : some View {
        if $appModel.settings.shareFeedback.wrappedValue {
            
            BorderedTextEditorView(placeholder: LocalizableSettings.selectFeedback.localized,
                                   shouldShowTitle: true,
                                   fieldContent: $feedbackViewModel.feedbackContent,
                                   isValid: $feedbackViewModel.feedbackIsValid)
        }
    }
    
    var submitButton : some View {
        
        VStack() {
            Spacer()
            TellaButtonView<AnyView> (title:  LocalizableSettings.submit.localized ,
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: $feedbackViewModel.feedbackIsValid) {
                feedbackViewModel.submitFeedback()
                
            } .padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
        }
    }
    
 
    private func showSaveFeedbackConfirmationView() {
        if feedbackViewModel.shouldShowSaveDraftSheet  {
            self.showSaveDraftSheet = true
        } else {
            self.dismiss()
        }
    }
    
    var confirmBottomSheet: some View {
        DragView(modalHeight: 200, isShown: $showSaveDraftSheet) {
            ConfirmBottomSheet(titleText: LocalizableSettings.exitFeedbackTitle.localized,
                               msgText: LocalizableSettings.exitFeedbackSheetExpl.localized,
                               cancelText: LocalizableSettings.exitFeedbackSheetAction.localized.uppercased(),
                               actionText:LocalizableSettings.exitFeedbackSaveSheetAction.localized.uppercased(), didConfirmAction: {
                feedbackViewModel.saveFeedbackDraft()
                self.dismiss()
            }, didCancelAction: {
                self.dismiss()
            })
        }
    }
    
    private func handleFeedbackSentSuccessfully() {
        DispatchQueue.main.async {
            if feedbackViewModel.feedbackSentSuccessfully {
                self.dismiss()
                Toast.displayToast(message: LocalizableSettings.successSentToast.localized)
            }
        }
    }
    
    private func handleErrorToast() {
        DispatchQueue.main.async {
            if feedbackViewModel.showErrorToast {
                Toast.displayToast(message: LocalizableCommon.commonError.localized)
            }
        }
    }
}

#Preview {
    FeedbackView(mainAppModel: MainAppModel.stub())
        .environmentObject(MainAppModel.stub())
    
}
