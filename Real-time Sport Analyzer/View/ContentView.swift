//
//  ContentView.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//


import SwiftUI
import WatchConnectivity

//To track that files are actually being received and saved

struct ContentView: View {
    @StateObject var viewModel: AppConnectivityViewModel

    var body: some View {
        NavigationView {
            VStack {
                List() {
                    Section(
                        header: Text("Files tracker"),
                        footer: Text("Communicating by transferUserInfo")) {
                            VStack{
                                Text("Motion Data Collected:")
                                    .font(.headline)
                                    .padding()
                                Text("Soccer: \(viewModel.fileCountSoccer)")
                                Text("Basketball: \(viewModel.fileCountBasketball)")
                            }
                        }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: AppConnectivityViewModel()
        )
    }
}
