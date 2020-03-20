//
//  Utils.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

class Utils {
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                    return json.element(index: 0)
                } else {
                    return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    typealias Dict = [String: Any]
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    static func httpRequest(endpoint: URL, method: HttpMethod, params: Dict?, completion: @escaping (Result<Dict,Error>) -> Void) {
        var request = URLRequest(url: endpoint)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        if let json = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let data = data,
                let string = String(data: data, encoding: .utf8),
                let dict = Utils.convertToDictionary(text: string)
            else {
                print("No usable response")
                completion(.success([:]))
                return
            }
            
            completion(.success(dict))
            
            guard let response = response as? HTTPURLResponse else {
                print("response type is not HTTPURLResponse")
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                return
            }
        }
        task.resume()
    }
}
