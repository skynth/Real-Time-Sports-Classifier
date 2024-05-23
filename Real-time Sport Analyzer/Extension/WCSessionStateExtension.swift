//
//  WCSessionStateExtension.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//

import Foundation
import WatchConnectivity

extension WCSessionActivationState {
    func stateStr() -> String {
        switch self {
        case .inactive:
            return "INACTIVE"
        case .activated:
            return "ACTIVE"
        case .notActivated:
            return "NOT ACTIVE"
        @unknown default:
            fatalError("New DEFINED STATE");
        }
    }
}
