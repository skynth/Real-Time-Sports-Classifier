//
//  DataCollectionView.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/21/24.
//

import SwiftUI

struct DataCollectionView: View {
    @StateObject var viewModel: DataCollectionViewModel
    @State private var selectedActivity = "Soccer"

    var body: some View {
        VStack {
            Text("Data Collection")
                .font(.headline)
            
            Picker("Select Activity", selection: $selectedActivity) {
                Text("Soccer").tag("Soccer")
                Text("Basketball").tag("Basketball")
            }.pickerStyle(WheelPickerStyle())
                .padding(.horizontal)
            
            if !viewModel.isCollecting {
                Button(action: {
                    viewModel.startCollectingData(for: selectedActivity)
                }) {
                    Text("Start")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
            }
            } else{
                Button(action: {
                    viewModel.stopCycle()
                }) {
                    Text("Stop")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
            }

            if viewModel.isCollecting {
                Text("Time Remaining: \(viewModel.timeRemaining)")
                    .font(.headline)
                    .padding()
            }
            Text("\(viewModel.status)").font(.caption2)
            }
        }
}

struct DataCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        DataCollectionView(viewModel: DataCollectionViewModel()
        )
    }
}

