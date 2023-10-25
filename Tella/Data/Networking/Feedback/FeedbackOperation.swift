//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class FeedbackOperation:Operation, WebRepository {
    
    public var feedbackToSend : Feedback?
    public var mainAppModel :MainAppModel!
    
    private var cancellable: AnyCancellable?
    private var subscribers : Set<AnyCancellable> = []
    
    init(mainAppModel :MainAppModel) {
        super.init()
        self.mainAppModel = mainAppModel
        setupNetworkMonitor()
    }
    
    override func main() {
        super.main()
        submitFeedback()
    }
    
    private func setupNetworkMonitor() {
        cancellable =  self.mainAppModel.networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            if isConnected && self.feedbackToSend != nil {
                self.submitFeedback()
                self.cancellable = nil
            }
        })
    }
    
    public func submitFeedback() {
        
        if mainAppModel.networkMonitor.isConnected, let feedbackToSend, let text = feedbackToSend.text {
            
            let apiResponse : APIResponse<FeedbackDTO> = getAPIResponse(endpoint: FeedbackRepository.API.submitFeedback(text))
            
            apiResponse
                .compactMap{$0.0.toDomain() as? FeedbackAPI}
                .sink { result in
                    self.handleFeedbackResult(result:result, feedbackToSend:feedbackToSend)
                } receiveValue: { feedbackAPI in
                }.store(in: &subscribers)
        }
    }
    
    private func handleFeedbackResult(result:Subscribers.Completion<APIError>, feedbackToSend:Feedback) {
        switch result {
        case .finished:
            let message = String(format: LocalizableSettings.backgroundSuccessSentToast.localized)
            Toast.displayToast(message: message)
            self.mainAppModel.vaultManager.tellaData?.deleteFeedback(feedbackId: feedbackToSend.id)
            self.cancel()
        default:
            break
        }
    }
}
