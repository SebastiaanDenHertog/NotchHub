//
//  ContentView.swift
//  NotchHub
//
//  Created by Sebastiaan den Hertog on 10/02/2025.
//

import SwiftUI

struct ContentView: View {
    // 1) A callback for when the user taps "Settings"
    var onSettingsTapped: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Hello, Notch!")
                    .font(.title)
                
                Text("This is the overlay content.")
                    .font(.subheadline)
            }

            Spacer()

            // 2) A button to open Settings
            Button {
                onSettingsTapped()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(8)
    }
}

// SwiftUI preview
#Preview {
    ContentView {
        // Mock callback
        print("Settings tapped.")
    }
}
