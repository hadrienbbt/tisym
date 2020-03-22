//
//  NoBridge.swift
//  Tisym
//
//  Created by Hadrien Barbat on 2020-03-22.
//  Copyright © 2020 Hadrien Barbat. All rights reserved.
//

import SwiftUI

struct NoBridge: View {
    @ObservedObject var hueDelegate: HueDelegate
    
    var body: some View {
        VStack(alignment: .center, spacing: 20.0) {
            Text("No bridge found. please connect to the same network than your hue bridge and press retry")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: {
                self.hueDelegate.fetchBridge()
            }) { Text("Retry") }
        }
    }
}

struct NoBridge_Previews: PreviewProvider {
    static var previews: some View {
        NoBridge(hueDelegate: HueDelegate())
    }
}
