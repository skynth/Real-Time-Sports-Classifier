//
//  ContentView.swift
//  Real-time Sport Analyzer Watch App
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//


import SwiftUI

struct ContentView: View {
    @StateObject var detectionViewModel: SportDetectionViewModel
    @StateObject var collectionViewModel: DataCollectionViewModel

    var body: some View {
        TabView {
            SportDetectionView(viewModel: detectionViewModel)
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Detect")
                }

            DataCollectionView(viewModel: collectionViewModel)
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Collect")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(detectionViewModel: SportDetectionViewModel(), collectionViewModel: DataCollectionViewModel()
        )
    }
}
