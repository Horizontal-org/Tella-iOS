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
    @Published var showErrorToast : Bool = false
    
    private var subscribers = Set<AnyCancellable>()
    
    var shouldShowSaveDraftSheet: Bool {
        return feedbackIsValid && mainAppModel.settings.shareFeedback
    }
    
    var tellaData: TellaData?  {
        return self.mainAppModel.vaultManager.tellaData
    }
    
    var isNewFeedback: Bool {
        return ((self.feedback?.id) == nil)
    }
    
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
    
    public func saveFeedbackDraft() {
        saveFeedback(status: .draft)
    }
    
    @discardableResult
    private func saveFeedback(status:FeedbackStatus) -> Result<Bool, Error>? {
        isNewFeedback ? addFeedback(status: status) : updateFeedback(status: status)
    }
    
    private func updateFeedback(status:FeedbackStatus)  -> Result<Bool, Error>? {
        guard let tellaData else {
            return .failure(RuntimeError("Error"))
        }
        
        let feedback = Feedback(id:self.feedback?.id, text: feedbackContent, status: status)
        self.feedback = feedback
        return tellaData.updateFeedback(feedback: feedback)
        
    }
    
    private func addFeedback(status:FeedbackStatus) -> Result<Bool, Error>? {
        guard let tellaData else {
            return .failure(RuntimeError("Error"))
        }
        
        let feedback = Feedback(text: feedbackContent, status: status)
        let feedbackResult = tellaData.addFeedback(feedback: feedback)
        
        switch feedbackResult {
            
        case .success(let id):
            feedback.id = id
            self.feedback = feedback
            return .success(true)
            
        case .failure(let error):
            self.showErrorToast = true
            return .failure(error)
        }
        
    }
    
    public func submitFeedback() {
        let saveFeedbackResult = saveFeedback(status: .pending)
        
        if case .success = saveFeedbackResult {
            
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
    }
    
    private func handleFeedbackResult(result:Subscribers.Completion<APIError>) {
        switch result {
        case .finished:
            self.deleteCurrentDraft()
            self.feedbackSentSuccessfully = true
        case .failure(let error):
            switch error {
            case .noInternetConnection:
                self.showOfflineToast = true
            default:
                self.showErrorToast = true
            }
        }
    }
    
    func deleteCurrentDraft() {
        guard let feedback, let feedbackId = feedback.id else {
            initFeedback()
            return
        }
        self.mainAppModel.vaultManager.tellaData?.deleteFeedback(feedbackId: feedbackId)
        initFeedback()
    }
}
