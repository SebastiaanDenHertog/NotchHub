//
//  SettingsView.swift
//  NotchHub
//
//  Created by Sebastiaan den Hertog on 10/02/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var sliderValue: Double = 10.0
    @State private var toggleValue: Bool = false
    
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("NotchHub Settings")
                .font(.headline)
            
            Toggle("Some Feature", isOn: $toggleValue)
            
            HStack {
                Text("Threshold: \(Int(sliderValue))")
                Slider(value: $sliderValue, in: 0...100)
            }

            Button("Close") {
                onClose()
            }
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    SettingsView {
        // Mock close action
    }
}
