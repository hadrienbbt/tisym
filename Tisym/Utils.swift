//
//  Utils.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-17.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

typealias Dict = [String: Any]

struct CieColor: Decodable, Encodable, Equatable, Hashable {
    let x: Double
    let y: Double
}

class Utils {
    
    static func rgbToHex(_ red: Int, _ green: Int, _ blue: Int) -> String {
        return String(format:"%02X", red) + String(format:"%02X", green) + String(format:"%02X", blue)
    }
    
    // From: https://github.com/usolved/cie-rgb-converter/blob/master/cie_rgb_converter.js
    static func rgbToCie(_ red: Int, _ green: Int, _ blue: Int) -> CieColor
    {
        //Apply a gamma correction to the RGB values, which makes the color more vivid and more the like the color displayed on the screen of your device
        let doubleRed = Double(red)
        let doubleGreen = Double(green)
        let doubleBlue = Double(blue)
        
        let red = (doubleRed > 0.04045) ? pow((doubleRed + 0.055) / (1.0 + 0.055), 2.4) : (doubleRed / 12.92)
        let green = (doubleGreen > 0.04045) ? pow((doubleGreen + 0.055) / (1.0 + 0.055), 2.4) : (doubleGreen / 12.92)
        let blue = (doubleBlue > 0.04045) ? pow((doubleBlue + 0.055) / (1.0 + 0.055), 2.4) : (doubleBlue / 12.92)
        
        //RGB values to XYZ using the Wide RGB D65 conversion formula
        let X = red * 0.664511 + green * 0.154324 + blue * 0.162028
        let Y = red * 0.283881 + green * 0.668433 + blue * 0.047685
        let Z = red * 0.000088 + green * 0.072310 + blue * 0.986039
        
        //Calculate the xy values from the XYZ values
        var x = Double(round(1000*(X / (X + Y + Z)))/1000)
        var y = Double(round(1000*(Y / (X + Y + Z)))/1000)
        
        if x.isNaN {
            x = 0
        }
        if y.isNaN {
            y = 0
        }
        return CieColor(x: x, y: y)
    }
    
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
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    static func httpRequest(endpoint: String, method: HttpMethod, params: Dict?, completion: @escaping (Result<Dict,Error>) -> Void) {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        
        print("Sending to \(endpoint.description)")
        if let json = params {
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            print("Params \(json.description)")
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
            
            if let error = dict["error"] as? [String: Any],
                let hueError: HueError = decode(json: error) {
                completion(.failure(hueError))
            } else {
                completion(.success(dict))
            }
            
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
