//
//  Color.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-23.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

class Color {
    let id: String
    let red: Int
    let green: Int
    let blue: Int
    let hex: String
    
    init(rgb: ColorRGB) {
        self.id = rgb.id
        self.red = rgb.red
        self.green = rgb.green
        self.blue = rgb.blue
        self.hex = Utils.rgbToHex(rgb)
    }
    
    init(hex: ColorHex) {
        self.id = hex.id
        self.hex = hex.hex
        let rgb = Utils.hexToRGB(hex.hex)!
        self.red = rgb.red
        self.green = rgb.green
        self.blue = rgb.blue
    }
    
    var description: String {
        return "id: \(id) - red: \(red) - green: \(green) - blue: \(blue) - hex: \(hex)"
    }
}

struct ColorRGB: Hashable, Codable, Identifiable {
    var id: String
    let red: Int
    let green: Int
    let blue: Int
}

struct ColorHex: Hashable, Codable, Identifiable {
    var id: String    
    let hex: String
}

struct CieColor: Decodable, Encodable, Equatable, Hashable {
    let x: Double
    let y: Double
}
