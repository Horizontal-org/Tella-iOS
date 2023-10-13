//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class FeedbackOperation:Operation {
    
    var feddbackToSend : Feedback?
    
    public var urlSession : URLSession!
    public var mainAppModel :MainAppModel!
    var feedbackRepository:FeedbackRepository!
    
    var subscribers : Set<AnyCancellable> = []
    @Published var response : AnyPublisher<FeedbackAPI,APIError>?
    
    init(urlSession:URLSession, mainAppModel :MainAppModel, feedbackRepository:FeedbackRepository) {
        super.init()
        
        self.urlSession = urlSession
        self.mainAppModel = mainAppModel
        self.feedbackRepository = feedbackRepository
        
        setupNetworkMonitor()
    }
    
    
    override func main() {
        super.main()
        submitFeedback()
    }
    
    private func setupNetworkMonitor() {
        self.mainAppModel.networkMonitor.connectionDidChange.sink(receiveValue: { isConnected in
            if self.feddbackToSend != nil {
                if isConnected && self.feddbackToSend?.status == .pending  {
                    self.submitFeedback()
                } else if !isConnected && self.feddbackToSend?.status != .pending {
                    // self.updateFeedback
                    // self.stopConnection()
                    debugLog("No internet connection")
                }
            }
        }).store(in: &subscribers)
    }
    
    func submitFeedback() {
        if mainAppModel.networkMonitor.isConnected {
            
            let apiResponse : APIResponse<FeedbackDTO> = feedbackRepository.getAPIResponse(endpoint: FeedbackRepository.API.submitFeedback("Test"))
            
            response =  apiResponse
                .compactMap{$0.0.toDomain() as? FeedbackAPI}
                .eraseToAnyPublisher()
         } else {
            
        }
    }
    
}
