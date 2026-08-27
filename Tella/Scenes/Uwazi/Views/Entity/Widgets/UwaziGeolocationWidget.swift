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
                                                        displayedLatitude(location.lat)),
                       style: .body2Style,
                       fillsWidth: true)
            
            CustomText(String.localizedStringWithFormat(LocalizableUwazi.uwaziEntityGeolocationLongitude.localized,
                                                        displayedLongitude(location.lon)),
                       style: .body2Style,
                       fillsWidth: true)
            
        }
    }
    
    private func displayedLatitude(_ latitude: Double) -> String {
        dmsString(decimalDegrees: latitude, positiveDirection: "N", negativeDirection: "S")
    }
    
    private func displayedLongitude(_ longitude: Double) -> String {
        dmsString(decimalDegrees: longitude, positiveDirection: "E", negativeDirection: "W")
    }
    
    private func dmsString(decimalDegrees: Double,
                           positiveDirection: String,
                           negativeDirection: String) -> String {
        let direction = decimalDegrees >= 0 ? positiveDirection : negativeDirection
        let totalSeconds = (abs(decimalDegrees) * 3600 * 100_000).rounded() / 100_000
        
        var degrees = Int(totalSeconds / 3600)
        let remainingSeconds = totalSeconds - Double(degrees) * 3600
        var minutes = Int(remainingSeconds / 60)
        var seconds = remainingSeconds - Double(minutes) * 60
        
        if seconds >= 60 {
            seconds = 0
            minutes += 1
        }
        if minutes >= 60 {
            minutes = 0
            degrees += 1
        }
        
        let secondsString = String(format: "%.5f", locale: Locale(identifier: "en_US_POSIX"), seconds)
        return "\(degrees)° \(minutes)' \(secondsString)\" \(direction)"
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
