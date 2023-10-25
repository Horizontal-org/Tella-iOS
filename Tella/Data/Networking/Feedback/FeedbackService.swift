//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class FeedbackService: NSObject {
    
    static var shared : FeedbackService = FeedbackService()
    private var operationQueue: OperationQueue!

    override init() {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        operationQueue = queue
    }
    
    func addFeedbackOperation(mainAppModel: MainAppModel, feedbackToSend : Feedback) {
        let operation = FeedbackOperation(mainAppModel: mainAppModel)
        operation.feedbackToSend = feedbackToSend
        operation.submitFeedback()
        operationQueue.addOperation(operation)
    }
    
    func addUnsentFeedbacksOperation(mainAppModel: MainAppModel) {
        
        let unsentFeedbacks = mainAppModel.vaultManager.tellaData?.getUnsentFeedbacks()
        
        unsentFeedbacks?.forEach({ feedback in
            let operation = FeedbackOperation(mainAppModel: mainAppModel)
            operation.feedbackToSend = feedback
            operationQueue.addOperation(operation)
        })
    }
}
