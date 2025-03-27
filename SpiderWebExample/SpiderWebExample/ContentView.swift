//
//  ContentView.swift
//  SpiderWebExample
//  Created by ZXL on 2025/3/18
        

import SwiftUI
import SpiderWeb


struct ContentView: View {
    var t = TestClass(sw: SpiderWeb())
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
            Button("weaveWeb") {
                t.sw?.weaveWeb()
            }
            Button("cleanWeb") {
                t.sw?.cleanWeb()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
