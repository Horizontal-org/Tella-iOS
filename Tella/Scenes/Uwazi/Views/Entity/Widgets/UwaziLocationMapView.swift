//
//  UwaziLocationMapView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import MapKit
import CoreLocation

struct UwaziLocationMapView: View {
    
    @ObservedObject var prompt: UwaziGeolocationEntryPrompt
    var entityViewModel: UwaziEntityViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel: LocationPickerViewModel
    
    init(prompt: UwaziGeolocationEntryPrompt, entityViewModel: UwaziEntityViewModel) {
        self.prompt = prompt
        self.entityViewModel = entityViewModel
        let initialCoordinate = prompt.value.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
        }
        _viewModel = StateObject(wrappedValue: LocationPickerViewModel(initialCoordinate: initialCoordinate))
    }
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            mapContent
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .alert(isPresented: $viewModel.shouldShowPermissionDenied) {
            LocationPermissionAlert.denied {
                viewModel.shouldShowPermissionDenied = false
            }
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableUwazi.uwaziEntityGeolocationRecordTitle.localized,
                             backButtonType: .close,
                             rightButtonType: .validate,
                             rightButtonAction: { confirmSelection() },
                             isRightButtonEnabled: viewModel.selectedCoordinate != nil)
    }
    
    var mapContent: some View {
        ZStack(alignment: .top) {
            LocationMapViewRepresentable(coordinate: $viewModel.selectedCoordinate,
                                         recenterGeneration: viewModel.recenterGeneration)
            .ignoresSafeArea(edges: .bottom)
            
            ToastMessageView(message: LocalizableUwazi.uwaziEntityGeolocationMapHint.localized)
            
        }
    }
    
    private func confirmSelection() {
        guard let coordinate = viewModel.selectedCoordinate else { return }
        prompt.value = UwaziGeoLocation(lat: coordinate.latitude, lon: coordinate.longitude)
        entityViewModel.publishUpdates()
        presentationMode.wrappedValue.dismiss()
    }
}

final class LocationPickerViewModel: ObservableObject {
    
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var recenterGeneration: Int = 0
    @Published var shouldShowPermissionDenied = false
    
    private let locationManager = LocationManager()
    private let hadInitialCoordinate: Bool
    private var didAutoFillFromGPS = false
    
    init(initialCoordinate: CLLocationCoordinate2D?) {
        selectedCoordinate = initialCoordinate
        hadInitialCoordinate = initialCoordinate != nil
        if initialCoordinate != nil {
            recenterGeneration = 1
        }
        locationManager.observer = self
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func selectCoordinate(_ coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        recenterGeneration += 1
    }
    
    private func handleLocationUpdate(_ location: CLLocation) {
        guard !hadInitialCoordinate, !didAutoFillFromGPS else { return }
        didAutoFillFromGPS = true
        selectCoordinate(location.coordinate)
        locationManager.stopUpdatingLocation()
    }
}

extension LocationPickerViewModel: LocationManagerObserver {
    func locationManager(_ manager: LocationManager, didFailWithError error: any Error) {
        
    }
    
    func locationManager(_ manager: LocationManager, didUpdate location: CLLocation) {
        handleLocationUpdate(location)
    }
    
    func locationManager(_ manager: LocationManager,
                         didChangeAuthorization authorizationState: LocationManager.AuthorizationState) {
        shouldShowPermissionDenied = authorizationState == .denied
    }
}

struct LocationMapViewRepresentable: UIViewRepresentable {
    
    @Binding var coordinate: CLLocationCoordinate2D?
    var recenterGeneration: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        
        let longPress = UILongPressGestureRecognizer(target: context.coordinator,
                                                     action: #selector(Coordinator.handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        longPress.allowableMovement = 40
        longPress.delegate = context.coordinator
        mapView.addGestureRecognizer(longPress)
        
        context.coordinator.syncAnnotation(on: mapView, recenter: true)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        let shouldRecenter = context.coordinator.lastRecenterGeneration != recenterGeneration
        context.coordinator.lastRecenterGeneration = recenterGeneration
        context.coordinator.syncAnnotation(on: mapView, recenter: shouldRecenter)
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: LocationMapViewRepresentable
        var lastRecenterGeneration: Int = 0
        
        init(_ parent: LocationMapViewRepresentable) {
            self.parent = parent
        }
        
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began, let mapView = gesture.view as? MKMapView else { return }
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            parent.coordinate = coordinate
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer is UILongPressGestureRecognizer
        }
        
        func syncAnnotation(on mapView: MKMapView, recenter: Bool) {
            let existing = mapView.annotations.compactMap { $0 as? MKPointAnnotation }.first
            
            if let coordinate = parent.coordinate {
                if let existing {
                    existing.coordinate = coordinate
                } else {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                }
                
                if recenter {
                    let region = MKCoordinateRegion(center: coordinate,
                                                    latitudinalMeters: 800,
                                                    longitudinalMeters: 800)
                    mapView.setRegion(region, animated: true)
                }
            } else if existing != nil {
                mapView.removeAnnotations(mapView.annotations.filter { $0 is MKPointAnnotation })
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            let identifier = "UwaziLocationPin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pinView?.pinTintColor = .red
                pinView?.animatesDrop = true
                pinView?.canShowCallout = false
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        }
    }
}
