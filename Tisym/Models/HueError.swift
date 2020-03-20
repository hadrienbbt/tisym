//
//  HueError.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

struct HueError: Decodable, Error {
    let type: Int
    let address: String
    let description: String
    
    init(_ description: String = "Unknown Error") {
        self.type = 0
        self.address = ""
        self.description = description
    }
}
