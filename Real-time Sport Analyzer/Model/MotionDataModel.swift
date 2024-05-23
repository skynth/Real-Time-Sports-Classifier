//
//  DataModel.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//

import Foundation
import UIKit

struct MotionDataModel: Identifiable {
    let id = UUID()
    var activity: String
    var accelX: Double
    var accelY: Double
    var accelZ: Double
    var gyroX: Double
    var gyroY: Double
    var gyroZ: Double
    var magX: Double
    var magY: Double
    var magZ: Double
    var pace: Double
    var stepCount: Int
    var cadence: Double

    //Round to reduce file size for transfer
    var csvString: String {
        return "\(activity),\(accelX.roundedTo(places: 12)),\(accelY.roundedTo(places: 12)),\(accelZ.roundedTo(places: 12)),\(gyroX.roundedTo(places: 12)),\(gyroY.roundedTo(places: 12)),\(gyroZ.roundedTo(places: 12)),\(magX.roundedTo(places: 12)),\(magY.roundedTo(places: 12)),\(magZ.roundedTo(places: 12)),\(pace.roundedTo(places: 12)),\(stepCount),\(cadence.roundedTo(places: 12))"
    }
}
//need to round to certain decimal points to limit payload
extension Double {
    func roundedTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
