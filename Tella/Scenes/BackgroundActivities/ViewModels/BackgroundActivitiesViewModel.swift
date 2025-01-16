//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine
import UIKit

class BackgroundActivitiesViewModel:ObservableObject {
    
    @Published var items : [BackgroundActivityModel] = []
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel:MainAppModel) {
        
        mainAppModel.encryptionService?.$backgroundItems
            .sink(receiveValue: { items in
                self.items = items
                UIApplication.shared.isIdleTimerDisabled = !self.items.isEmpty
            }).store(in: &subscribers)
        
        
        
    }
}


