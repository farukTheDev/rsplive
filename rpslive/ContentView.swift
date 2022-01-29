//
//  ContentView.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 21.01.2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Login()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone XR"))
    }
}
