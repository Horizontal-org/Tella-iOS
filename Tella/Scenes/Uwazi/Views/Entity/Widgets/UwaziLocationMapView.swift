//
//  UwaziLocationMapView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import CoreLocation

struct UwaziLocationMapView: View {
    
    @ObservedObject var prompt: UwaziGeolocationEntryPrompt
    var entityViewModel: UwaziEntityViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    init(prompt: UwaziGeolocationEntryPrompt, entityViewModel: UwaziEntityViewModel) {
        self.prompt = prompt
        self.entityViewModel = entityViewModel
        _selectedCoordinate = State(initialValue: prompt.value?.coordinate)
    }
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            mapContent
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableUwazi.uwaziEntityGeolocationRecordTitle.localized,
                             backButtonType: .close,
                             rightButtonType: .validate,
                             rightButtonAction: { confirmSelection() },
                             isRightButtonEnabled: selectedCoordinate != nil)
    }
    
    var mapContent: some View {
        ZStack(alignment: .top) {
            LocationPickerMap(coordinate: $selectedCoordinate)
                .ignoresSafeArea(edges: .bottom)
            
            ToastMessageView(message: LocalizableUwazi.uwaziEntityGeolocationMapHint.localized)
        }
    }
    
    private func confirmSelection() {
        guard let selectedCoordinate else { return }
        prompt.value = UwaziGeoLocation(coordinate: selectedCoordinate)
        entityViewModel.publishUpdates()
        presentationMode.wrappedValue.dismiss()
    }
}
