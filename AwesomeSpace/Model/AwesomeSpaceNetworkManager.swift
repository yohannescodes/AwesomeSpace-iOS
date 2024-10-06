//
//  AwesomeSpaceNetworkManager.swift
//  AwesomeSpace
//
//  Created by Yohannes Haile on 10/5/24.
//

import Foundation

class AwesomeSpaceNetworkManager {
    
    static let shared = AwesomeSpaceNetworkManager()
    
    let baseURL = "https://awesomespace.onrender.com/api/find-exoplanet"
    
    
    private func post<T: Decodable, U: Encodable>(path: String, parameters: U) async throws -> T {
        
        let url = URL(string: path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(parameters)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await sendRequest(request)
    }
    
    private func sendRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        
        var data = Data()
        
        do {
            
            (data, _) = try await URLSession.shared.data(for: request)
            
        }catch {
            
            print("Network request error: \(error)")
            throw AwesomeSpaceNetworkError.networkError(error)
        }
        
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
            print(jsonResult)
            
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Decoding error: \(error)")
            throw AwesomeSpaceNetworkError.decodingError(error)
        }
    }
    
    func findExoplanet(request: ScannedSpace) async throws -> ExoplanetResponse{
        return try await post(path: baseURL, parameters: request)
    }
    
}
