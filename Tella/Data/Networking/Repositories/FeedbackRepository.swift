//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

struct FeedbackRepository: WebRepository {
    
    func submitFeedback(feedback: Feedback, mainAppModel: MainAppModel) -> AnyPublisher<FeedbackAPI,APIError>? {
        
        if !mainAppModel.networkMonitor.isConnected {
            FeedbackService.shared.addFeedbackOperation(mainAppModel: mainAppModel, feedbackToSend: feedback)
        }
        
        let apiResponse : APIResponse<FeedbackDTO> = getAPIResponse(endpoint: FeedbackRepository.API.submitFeedback(feedback.text))
        return apiResponse
            .compactMap{$0.0.toDomain() as? FeedbackAPI}
            .eraseToAnyPublisher()
    }
}

extension FeedbackRepository {
    enum API {
        case submitFeedback((String?))
    }
}

extension FeedbackRepository.API: APIRequest {
    
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .submitFeedback((let text)):
            return [
                "platform": Platform.ios.rawValue,
                "text": text]
        }
    }
    
    var baseURL: String {
        switch self {
        case .submitFeedback:
            return "https://api.feedback.tella-app.org"
        }
    }
    
    var path: String {
        switch self {
        case .submitFeedback:
            return "/opinions"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .submitFeedback:
            return HTTPMethod.post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .submitFeedback:
            return [HTTPHeaderField.tellaPlatform.rawValue:"wearehorizontal"]
        }
    }
}


enum Platform : String {
    case ios = "IOS"
}
