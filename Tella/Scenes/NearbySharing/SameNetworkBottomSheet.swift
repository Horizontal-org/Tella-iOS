//
//  SameNetworkBottomSheet.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/2/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct SameNetworkBottomSheet: View {
    
    @State var isChecked: Bool = false
    @StateObject var mainAppModel: MainAppModel
    var didConfirm: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            
            CustomText(LocalizableNearbySharing.sameNetworkSheetTitle.localized,
                       style: .heading2Style)
            Spacer()
                .frame(height: .extraSmall)
            
            CustomText(LocalizableNearbySharing.sameNetworkSheetExpl.localized,
                       style: .body1Style)
            Spacer()
                .frame(height: .small)
            
            dontShowAgainView
            
            Spacer()
            
            buttonsView
        }
    }
    
    var dontShowAgainView: some View {
        
        HStack() {
            Button {
                isChecked.toggle()
                
            } label: {
                Image(isChecked ? .checkboxOn : .checkboxOff )
                    .padding(EdgeInsets(top: .smallMedium, leading: 0, bottom: .smallMedium, trailing: .normal))
            }
            
            CustomText(LocalizableNearbySharing.dontShowAgain.localized,
                       style: .body1Style)
            
            Spacer()
        }
    }
    
    var buttonsView: some View {
        
        HStack(alignment: .lastTextBaseline) {
            Spacer()
            
            Button(action: {
                self.dismiss()
            }){
                Text(LocalizableNearbySharing.sameNetworkNoAction.localized.uppercased())
            }.buttonStyle(ButtonSheetStyle())
            
            Spacer()
                .frame(width: 10)
            
            Button(action: {
                self.dismiss {
                    didConfirm()
                    
                    mainAppModel.settings.showSameWiFiNetworkAlert = !isChecked
                    mainAppModel.saveSettings()
                }
            }){
                Text(LocalizableNearbySharing.sameNetworkYesAction.localized.uppercased())
            }.buttonStyle(ButtonSheetStyle())
        }
    }
}

#Preview {
    SameNetworkBottomSheet(mainAppModel: MainAppModel.stub(), didConfirm: {} )
}
