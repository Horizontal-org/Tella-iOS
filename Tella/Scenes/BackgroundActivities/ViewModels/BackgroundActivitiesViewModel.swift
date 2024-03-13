//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class BackgroundActivitiesViewModel:ObservableObject {
    
    @Published var items : [BackgroundActivityModel] = []
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel:MainAppModel) {
        
        mainAppModel.encryptionService?.$items
            .sink(receiveValue: { items in
                self.items = items
            }).store(in: &subscribers)
        
        
        
    }
}


