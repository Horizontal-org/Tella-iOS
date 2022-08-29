//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsCardView<T:View> : View {
    
    var cardDataArray : [CardData<T>]
    
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    @EnvironmentObject var appModel : MainAppModel
    
    var completion : ((CardName) -> ())?
    
    var body : some View {
        
        VStack(spacing: 0) {
            
            ForEach(Array(cardDataArray.enumerated()), id:\.element) { index, cardData in

                switch cardData.cardType {
                    
                case .link:
                    
                    Link(destination: URL(string: cardData.linkURL)!) {
                        SettingsItemView(imageName: cardData.imageName,
                                         title: cardData.title,
                                         value: cardData.value)
                    }
                    
                case .toggle:
                    
                    SettingToggleItem(title: cardData.title,
                                      description: cardData.description,
                                      toggle: cardData.valueToSave)
                    
                case .display:
                    
                    SettingsItemView(imageName: cardData.imageName,
                                     title: cardData.title,
                                     value: cardData.value)
                    
                    .if((cardData.destination != nil) , transform: { view in
                        view.navigateTo(destination: cardData.destination
                            .environmentObject(settingsViewModel))
                        
                    })
                        .onTapGesture {
                        cardData.action?()
                        completion?(cardData.cardName)
                    }
                }
                
                if index < cardDataArray.count - 1 {
                    DividerView()
                }
            }
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 5, leading: 17, bottom: 5, trailing: 17))
    }
}

struct DividerView : View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color.white.opacity(0.2))
    }
}

struct SettingsCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCardView<AnyView>(cardDataArray: [])
    }
}
