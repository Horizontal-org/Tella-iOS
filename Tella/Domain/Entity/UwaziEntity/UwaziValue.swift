//
//  UwaziValue.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import CoreLocation

class UwaziValue<T:Codable>: ObservableObject, Codable {
    
    @Published var value : T
    
    
    private enum CodingKeys: String, CodingKey {
        case value = "value"
        
    }
    init(value : T, label: String? = nil, type: String? = nil) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(T.self, forKey: .value)
    }
    
}

struct UwaziGeoLocation: Codable, Equatable {
    var lat: Double
    var lon: Double
    var label: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    enum CodingKeys: String, CodingKey {
        case lat, lon, label
    }
    
    init(lat: Double, lon: Double, label: String = "") {
        self.lat = lat
        self.lon = lon
        self.label = label
    }
    
    init(coordinate: CLLocationCoordinate2D, label: String = "") {
        self.init(lat: coordinate.latitude, lon: coordinate.longitude, label: label)
    }
    
    init?(dictionary: [String: Any]) {
        func doubleValue(for key: String) -> Double? {
            if let value = dictionary[key] as? Double { return value }
            if let value = dictionary[key] as? Int { return Double(value) }
            if let value = dictionary[key] as? NSNumber { return value.doubleValue }
            if let value = dictionary[key] as? String { return Double(value) }
            return nil
        }
        
        guard let lat = doubleValue(for: "lat"), let lon = doubleValue(for: "lon") else {
            return nil
        }
        
        self.lat = lat
        self.lon = lon
        self.label = dictionary["label"] as? String ?? ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lon, forKey: .lon)
        try container.encode(label, forKey: .label)
    }
}
