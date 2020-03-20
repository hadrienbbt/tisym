//
//  extensions.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-20.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import Foundation

extension Array {
    func element<T>(index: Int) -> T? {
        if self.count <= index {
            return nil
        }
        return self[index] as? T
    }
}
