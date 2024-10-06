//
//  AwesomeSpaceNetworkError.swift
//  AwesomeSpace
//
//  Created by Yohannes Haile on 10/6/24.
//

import Foundation

enum AwesomeSpaceNetworkError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

extension AwesomeSpaceNetworkError: LocalizedError {
    var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please try again later."
        case .networkError(_):
            return "Your device seems to be offline. Please check your internet connection."
        case .decodingError(_):
            return "There seems to be a problem from our side. We are working on it."
        }
    }
}


