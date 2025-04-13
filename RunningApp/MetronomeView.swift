//
//  MetronomeView.swift
//  RunningApp
//
//  Created by Ryan S on 4/12/25.
//

import SwiftUI
import Observation

struct MetronomeView: View {
    @State private var viewModel = MetronomeViewModel()

    var body: some View {
        MetronomeControls(viewModel: viewModel)
    }
}

struct MetronomeControls: View {
    @Bindable var viewModel: MetronomeViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("BPM: \(Int(viewModel.bpm))")
                .font(.largeTitle)

            Slider(value: $viewModel.bpm, in: 40...240, step: 1)
                .padding()

            Button(action: {
                viewModel.toggleMetronome()
            }) {
                Text(viewModel.isRunning ? "Stop" : "Start")
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    MetronomeView()
}
