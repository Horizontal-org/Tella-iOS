//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class FeedbackViewModel : ObservableObject {
    
    var mainAppModel: MainAppModel
    var feedback : Feedback?
    var feedbackId : Int?
    
    @Published var feedbackContent : String = ""
    @Published var feedbackIsValid : Bool = false
    
    
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
        self.initFeedback()
    }
    
    func initFeedback() {
        let feedback = self.mainAppModel.vaultManager.tellaData?.getCurrentFeedback()
        self.feedbackContent = self.feedback?.text ?? ""
        self.feedbackId = feedback?.id
    }
    
    func saveFeedbackDraft()   {
        saveFeedback(status: .draft)
    }
    
    func saveFeedback(status:FeedbackStatus) {
        guard let feedbackId else {
            let feedback = Feedback(text: feedbackContent, status: status)
            feedbackId = self.mainAppModel.vaultManager.tellaData?.addFeedback(feedback: feedback)
            return
        }
        let feedback = Feedback(id:feedbackId, text: feedbackContent, status: status)
        self.mainAppModel.vaultManager.tellaData?.updateFeedback(feedback: feedback)
    }
    
    func submitFeedback() {
        
        saveFeedback(status: .pending)
        
        
        
        FeedbackRepository().submitFeedback(text: feedbackContent, mainAppModel: mainAppModel)?
            .sink { result in
                
                switch result {
                case .finished:
                    self.mainAppModel.vaultManager.tellaData?.deleteFeedback(feedbackId: self.feedbackId)
                    
                    break
                case .failure(let error):
                    break
                }
            } receiveValue: { feedback in
                dump(feedback)
            }.store(in: &subscribers)
    }
}
