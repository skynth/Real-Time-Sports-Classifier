//
//  Real_time_Sport_AnalyzerApp.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//

import SwiftUI

@main
struct Real_time_Sport_AnalyzerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: AppConnectivityViewModel()
            )
        }
    }
}
