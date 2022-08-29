//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

class CardData<T:View>: Hashable, ObservableObject {
    
    var imageName : String
    var title : String
    var value : String
    var description : String
    var linkURL : String
    var cardType : CardType
    var cardName : CardName
    var destination : T?
    var valueToSave : Binding<Bool> = .constant(false)
    var action : (() -> ())?
    
    static func == (lhs: CardData, rhs: CardData) -> Bool {
        lhs.title  == rhs.title
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(title.hashValue)
    }
    
    init(imageName : String = "" ,
         title : String = "", description : String = "",
         linkURL : String = "",
         value : String = "",
         cardType : CardType,
         cardName : CardName,
         destination:T? = nil,
         valueToSave : Binding<Bool> = .constant(false),
         action : (() -> ())? = nil ) {
        
        self.imageName = imageName
        self.title = title
        self.description = description
        self.linkURL = linkURL
        self.value = value
        self.cardType = cardType
        self.cardName = cardName
        self.destination = destination
        self.valueToSave = valueToSave
        self.action = action
    }
}
