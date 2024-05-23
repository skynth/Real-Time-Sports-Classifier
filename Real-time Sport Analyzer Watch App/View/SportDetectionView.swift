//
//  SportDetectionView.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/21/24.
//

import SwiftUI

struct SportDetectionView: View {
    @ObservedObject var viewModel: SportDetectionViewModel

    var body: some View {
        VStack {
            Text("Sport Detection⚽️🏀")
                .font(.caption)
                .bold()
                .padding()
                .multilineTextAlignment(.center)
            
            Text("Current Activity:")
                .font(.subheadline)

            Text("\(viewModel.currentPrediction)")
                .font(.body)
                .padding()
                .padding(.horizontal, 20)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(.green)
                )
                .padding()
                            
        }.frame(maxWidth: .infinity)

        .onAppear {
            viewModel.startDetection()
        }
    }
}

struct SportDetectionView_Previews: PreviewProvider {
    static var previews: some View {
        SportDetectionView(viewModel: SportDetectionViewModel())
    }
}
