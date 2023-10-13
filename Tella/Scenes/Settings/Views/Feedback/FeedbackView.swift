//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct FeedbackView: View {
    
    @StateObject var feedbackViewModel : FeedbackViewModel
    @EnvironmentObject var appModel : MainAppModel
    @EnvironmentObject var sheetManager : SheetManager
    @State var isPresented : Bool = false
    
    init(mainAppModel:MainAppModel) {
        _feedbackViewModel = StateObject(wrappedValue: FeedbackViewModel(mainAppModel: mainAppModel))
    }
    
    var body: some View {
        ContainerView {
            content
        }
    }
    
    var content : some View {
        
        ZStack {
            VStack() {
                
                VStack(spacing: 24) {
                    
                    CloseHeaderView(title: "Feedback") {
                        showSaveFeedbackConfirmationView()
                    }
                    
                    introductionView
                    
                    dividerView
                    
                    manageFeedbackView
                    
                    feedbackTextView
                }
                
                Spacer()
            }
            
            VStack() {
                Spacer()
                submitButton
            }
            
            confirmBottomSheet
        }
    }
    
    var introductionView : some View {
        
        CardFrameView {
            HStack(spacing: 0) {
                
                Image("settings.share-data")
                
                Spacer().frame(width: 24)
                
                Text("Tell us if you are experiencing a bug, have a request for a new feature, or have any other feedback.\n\nThis feedback is anonymous, so make sure to include contact information if you want a response from us.")
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
            SettingToggleItem(title: "Enable feedback sharing",
                              description: "WARNING: using this feature may reveal to someone observing the network that you use Tella. Only use if you feel comfortable with this risk. Learn more." ,
                              toggle: $appModel.settings.shareFeedback)
        }
    }
    
    @ViewBuilder
    var feedbackTextView : some View {
        if $appModel.settings.shareFeedback.wrappedValue {
            
            BorderedTextEditorView(placeholder: "Feedback",
                                   fieldContent: $feedbackViewModel.feedbackContent,
                                   isValid: $feedbackViewModel.feedbackIsValid,
                                   shouldShowTitle: true)
        }
    }
    
    var submitButton : some View {
        
        TellaButtonView<AnyView> (title: "Submit",
                                  nextButtonAction: .action,
                                  buttonType: .yellow,
                                  isValid: $feedbackViewModel.feedbackIsValid) {
            feedbackViewModel.submitFeedback()
        } .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
        
    }
    
    
    
    private func showSaveFeedbackConfirmationView() {
        self.isPresented = true
    }
    
    var confirmBottomSheet: some View {
        DragView(modalHeight: 200, isShown: $isPresented) {
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
}

#Preview {
    FeedbackView(mainAppModel: MainAppModel.stub())
        .environmentObject(MainAppModel.stub())
    
}



