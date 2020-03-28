//
//  Color.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-23.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

struct Color: Hashable, Codable, Identifiable {
    var id: String
    let red: Int
    let green: Int
    let blue: Int
}
