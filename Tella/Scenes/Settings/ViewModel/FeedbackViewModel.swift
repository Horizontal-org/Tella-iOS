//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class FeedbackViewModel : ObservableObject {
    
    var mainAppModel: MainAppModel
    var feedback : Feedback?
    
    @Published var feedbackContent : String = ""
    @Published var feedbackIsValid : Bool = false
    @Published var feedbackSentSuccessfully : Bool = false
    @Published var showOfflineToast : Bool = false
    @Published var isLoading : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.initFeedback()
    }
    
    private func initFeedback() {
        let feedback = self.mainAppModel.vaultManager.tellaData?.getDraftFeedback()
        self.feedback = feedback
        self.feedbackContent = self.feedback?.text ?? ""
        feedbackIsValid = self.feedback?.text != nil
    }
    
    public func saveFeedbackDraft()   {
        saveFeedback(status: .draft)
    }
    
    private func saveFeedback(status:FeedbackStatus) {
        guard let feedbackId = self.feedback?.id else {
            let feedback = Feedback(text: feedbackContent, status: status)
            feedback.id = self.mainAppModel.vaultManager.tellaData?.addFeedback(feedback: feedback)
            self.feedback = feedback
            return
        }
        let feedback = Feedback(id:feedbackId, text: feedbackContent, status: status)
        self.feedback = feedback
        self.mainAppModel.vaultManager.tellaData?.updateFeedback(feedback: feedback)
    }
    
    public func submitFeedback() {
        saveFeedback(status: .pending)
        guard let feedback else { return }
        isLoading = true
        
        FeedbackRepository().submitFeedback(feedback: feedback, mainAppModel: mainAppModel)?
            .receive(on: DispatchQueue.main)
            .sink { result in
                self.isLoading = false
                self.handleFeedbackResult(result:result)
            } receiveValue: { feedback in
            }.store(in: &subscribers)
    }
    
    private func handleFeedbackResult(result:Subscribers.Completion<APIError>) {
        guard let feedback  else { return }
        switch result {
        case .finished:
            self.mainAppModel.vaultManager.tellaData?.deleteFeedback(feedbackId: feedback.id)
            self.feedbackSentSuccessfully = true
        case .failure(let error):
            switch error {
            case .noInternetConnection:
                self.showOfflineToast = true
            default:
                break
            }
        }
    }
}
