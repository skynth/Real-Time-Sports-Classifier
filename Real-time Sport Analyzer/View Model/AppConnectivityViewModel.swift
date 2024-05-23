//
//  AppConnectivityViewModel.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//

import SwiftUI
import WatchConnectivity

final class AppConnectivityViewModel: NSObject, ObservableObject {
    
    //TRACKING FILE CREATIONS
    @Published var fileCountSoccer: Int = 0
    @Published var fileCountBasketball: Int = 0
    
    private var session: WCSession = .default

    override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
}

extension AppConnectivityViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
        
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        guard let csvText = userInfo["data"] as? String,
              let activity = userInfo["activity"] as? String else {
            print("Failed to decode message data")
            return
        }
        saveCSV(data: csvText, for: activity)
    }
    
    private func saveCSV(data: String, for activity: String) {
        let fileName = generateUniqueFileName(for: activity)
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(activity)/\(fileName)")
        
        let headers = "Activity,AccelX,AccelY,AccelZ,GyroX,GyroY,GyroZ,MagX,MagY,MagZ,Pace,StepCount,Cadence\n"
        let csvData = headers + data
        
        do {
            try csvData.write(to: path, atomically: true, encoding: .utf8)
            print("Data saved to: \(path)")
            DispatchQueue.main.async {
                if(activity == "Soccer"){
                    self.fileCountSoccer += 1
                }
                else if (activity == "Basketball"){
                    self.fileCountBasketball += 1
                }
            }
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    private func generateUniqueFileName(for activity: String) -> String {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var fileNumber = 1
        var fileName = "\(activity)_\(fileNumber).csv"
        
        while FileManager.default.fileExists(atPath: documentsDirectory.appendingPathComponent("\(activity)/\(fileName)").path) {
            fileNumber += 1
            fileName = "\(activity)_\(fileNumber).csv"
        }
        return fileName
    }
    

}
