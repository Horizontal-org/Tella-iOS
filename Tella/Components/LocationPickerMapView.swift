//
//  LocationPickerMapView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 30/8/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import MapKit

final class LocationPickerMapView: MKMapView {
    
    var onCoordinateSelected: ((CLLocationCoordinate2D) -> Void)?
    var onMapFinishedLoading: (() -> Void)?
    
    private static let regionSpanMeters: CLLocationDistance = 800
    private static let pinReuseIdentifier = "LocationPickerPin"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func applySelection(_ coordinate: CLLocationCoordinate2D?) {
        guard hasCoordinateChanged(coordinate) else { return }
        setSelectedCoordinate(coordinate, recenter: true)
    }
    
    private var selectedAnnotation: MKPointAnnotation? {
        annotations.compactMap { $0 as? MKPointAnnotation }.first
    }
    
    private func setup() {
        delegate = self
        showsCompass = true
        
        let longPress = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(handleLongPress(_:)))
        longPress.allowableMovement = 40
        longPress.delegate = self
        addGestureRecognizer(longPress)
    }
    
    private func hasCoordinateChanged(_ coordinate: CLLocationCoordinate2D?) -> Bool {
        switch (selectedAnnotation?.coordinate, coordinate) {
        case (nil, .some):
            return true
        case let (.some(current), .some(new)):
            return current.latitude != new.latitude || current.longitude != new.longitude
        case (.some, nil):
            return true
        default:
            return false
        }
    }
    
    private func setSelectedCoordinate(_ coordinate: CLLocationCoordinate2D?, recenter: Bool) {
        if let coordinate {
            if let selectedAnnotation {
                selectedAnnotation.coordinate = coordinate
            } else {
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                addAnnotation(annotation)
            }
            
            if recenter {
                let region = MKCoordinateRegion(center: coordinate,
                                                latitudinalMeters: Self.regionSpanMeters,
                                                longitudinalMeters: Self.regionSpanMeters)
                setRegion(region, animated: true)
            }
        } else if let selectedAnnotation {
            removeAnnotation(selectedAnnotation)
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: self)
        let coordinate = convert(point, toCoordinateFrom: self)
        setSelectedCoordinate(coordinate, recenter: false)
        onCoordinateSelected?(coordinate)
    }
}

extension LocationPickerMapView: MKMapViewDelegate {
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        onMapFinishedLoading?()
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        onMapFinishedLoading?()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: Self.pinReuseIdentifier)
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: Self.pinReuseIdentifier)
        pinView.annotation = annotation
        pinView.image = UIImage(named: "uwazi.location")
        pinView.canShowCallout = false
        if let height = pinView.image?.size.height {
            pinView.centerOffset = CGPoint(x: 0, y: -height / 2)
        }
        return pinView
    }
}

extension LocationPickerMapView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UILongPressGestureRecognizer
    }
}

struct LocationPickerMap: View {
    
    @Binding var coordinate: CLLocationCoordinate2D?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            LocationPickerMapRepresentable(coordinate: $coordinate,
                                           onMapFinishedLoading: { isLoading = false })
            
            if isLoading {
                CircularLoader()
            }
        }
    }
}

private struct LocationPickerMapRepresentable: UIViewRepresentable {
    
    @Binding var coordinate: CLLocationCoordinate2D?
    var onMapFinishedLoading: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(coordinate: $coordinate, onMapFinishedLoading: onMapFinishedLoading)
    }
    
    func makeUIView(context: Context) -> LocationPickerMapView {
        let mapView = LocationPickerMapView()
        mapView.onCoordinateSelected = { [weak coordinator = context.coordinator] coordinate in
            coordinator?.coordinate.wrappedValue = coordinate
        }
        mapView.onMapFinishedLoading = { [weak coordinator = context.coordinator] in
            coordinator?.onMapFinishedLoading()
        }
        mapView.applySelection(coordinate)
        return mapView
    }
    
    func updateUIView(_ mapView: LocationPickerMapView, context: Context) {
        context.coordinator.coordinate = $coordinate
        context.coordinator.onMapFinishedLoading = onMapFinishedLoading
        mapView.applySelection(coordinate)
    }
    
    final class Coordinator {
        var coordinate: Binding<CLLocationCoordinate2D?>
        var onMapFinishedLoading: () -> Void
        
        init(coordinate: Binding<CLLocationCoordinate2D?>, onMapFinishedLoading: @escaping () -> Void) {
            self.coordinate = coordinate
            self.onMapFinishedLoading = onMapFinishedLoading
        }
    }
}
