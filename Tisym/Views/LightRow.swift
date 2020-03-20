//
//  LightRow.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-19.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct LightRow: View {
    @Binding var light: Light
    
    var body: some View {
        Toggle(isOn: $light.isOn) {
            Text(light.description)
        }
    }
}
