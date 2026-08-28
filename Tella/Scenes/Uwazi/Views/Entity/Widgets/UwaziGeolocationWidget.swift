//
//  UwaziGeolocationWidget.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziGeolocationWidget: View {
    @ObservedObject var prompt: UwaziGeolocationEntryPrompt
    var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            
            
            if let location = prompt.value {
                selectedLocationView(location: location)
            } else {
                CustomText(LocalizableUwazi.uwaziEntityGeolocationExpl.localized,
                           style: .body2Style,
                           fillsWidth: true)
                
                addLocationButton
            }
        }
        .onChange(of: prompt.value) { _ in
            entityViewModel.publishUpdates()
        }
    }
    
    var addLocationButton: some View {
        Button {
            openMap()
        } label: {
            UwaziActionRow(icon: .uwaziLocation,
                           title: LocalizableUwazi.uwaziEntityGeolocationAddLocation.localized)
        }
    }
    
    func selectedLocationView(location: UwaziGeoLocation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            CustomText(String.localizedStringWithFormat(LocalizableUwazi.uwaziEntityGeolocationLatitude.localized,
                                                        location.lat.displayedLatitude),
                       style: .body2Style,
                       fillsWidth: true)
            
            CustomText(String.localizedStringWithFormat(LocalizableUwazi.uwaziEntityGeolocationLongitude.localized,
                                                        location.lon.displayedLongitude),
                       style: .body2Style,
                       fillsWidth: true)
            
        }
    }
    
    private func openMap() {
        navigateTo(destination: UwaziLocationMapView(prompt: prompt,
                                                     entityViewModel: entityViewModel))
    }
}

#Preview("Add location") {
    ContainerView {
        UwaziGeolocationWidget(prompt: .stub(),
                               entityViewModel: .stub())
        .padding()
    }
}

#Preview("Selected location") {
    ContainerView {
        UwaziGeolocationWidget(prompt: .stub(value: UwaziGeoLocation(lat: 1.2880607889,
                                                                     lon: -81.5131120111)),
                               entityViewModel: .stub())
        .padding()
    }
}
