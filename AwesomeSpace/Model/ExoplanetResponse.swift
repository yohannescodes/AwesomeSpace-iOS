//
//  ExoplanetResponse.swift
//  AwesomeSpace
//
//  Created by Yohannes Haile on 10/5/24.
//

import Foundation

// MARK: - ExoplanetResponse
struct ExoplanetResponse: Codable {
    let message: String
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let exoplanet: Exoplanet
}

// MARK: - Exoplanet
struct Exoplanet: Codable {
    let id, name, distanceFromEarth, orbitalPeriod: String
    let radius, mass, starType, habitabilityFactors: String
    let ra, dec: Double
    let color: String
    let rgbColor: Color
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case distanceFromEarth = "distance_from_earth"
        case orbitalPeriod = "orbital_period"
        case radius, mass
        case starType = "star_type"
        case habitabilityFactors = "habitability_factors"
        case ra, dec
        case color
        case rgbColor
        case v = "__v"
    }
}

struct Color: Codable {
    let r: Double
    let g: Double
    let b: Double
}
