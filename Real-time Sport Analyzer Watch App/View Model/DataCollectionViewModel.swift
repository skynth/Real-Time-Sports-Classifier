//
//  DataCollectionViewModel.swift
//  Real-time Sport Analyzer Watch App
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/18/24.
//

import SwiftUI
import WatchConnectivity
import CoreMotion

//We collect data in 10 second intervals, 100 times per sport! Collection automatically stops after 100 iterations

final class DataCollectionViewModel: NSObject, ObservableObject {
    @Published var status: String = "Idle"
    @Published var timeRemaining: Int = 10
    @Published var isCollecting: Bool = false
    @Published var motionData: [MotionDataModel] = []
    
    private var session: WCSession = .default
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var timer: Timer?
    private var collectionTimer: Timer?
    private var currentPace: Double = 0.0
    private var currentStepCount: Int = 0
    private var currentCadence: Double = 0.0
    //To keep track for the loop
    private var numTrans: Int = 0
    private var currentActivity: String = ""

    override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    // Start data collection
    func startCollectingData(for activity: String) {
            timeRemaining = 10
            isCollecting = true
            motionData = []
        if(currentActivity != activity) {
            numTrans = 0 //reset because we are collecting to a different sport
        }
        currentActivity = activity

        if motionManager.isDeviceMotionAvailable {
            print("Device motion is available.")
            provideHapticFeedback()
            motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
            motionManager.showsDeviceMovementDisplay = true
            startPedometerUpdates()

            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.current!) { [weak self] (data, error) in
                if let validData = data {
                    let rX = validData.rotationRate.x
                    let rY = validData.rotationRate.y
                    let rZ = validData.rotationRate.z
                    let accelX = validData.userAcceleration.x
                    let accelY = validData.userAcceleration.y
                    let accelZ = validData.userAcceleration.z
                    let magX = validData.magneticField.field.x
                    let magY = validData.magneticField.field.y
                    let magZ = validData.magneticField.field.z

                    let record = MotionDataModel(
                        activity: activity,
                        accelX: accelX,
                        accelY: accelY,
                        accelZ: accelZ,
                        gyroX: rX,
                        gyroY: rY,
                        gyroZ: rZ,
                        magX: magX,
                        magY: magY,
                        magZ: magZ,
                        pace: self?.currentPace ?? 0,
                        stepCount: self?.currentStepCount ?? 0,
                        cadence: self?.currentCadence ?? 0
                    )
                    self?.motionData.append(record)
                }
            }
            collectionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.updateCountdown()
            }
            status = "Collecting \(activity) data"
        } else {
            status = "No Motion Data"
            print("Device motion not available.")
        }
    }
    
    private func provideHapticFeedback() {
        WKInterfaceDevice.current().play(.start)
    }
    
    
    private func startPedometerUpdates() {
        print("collecting pedometer data")
        pedometer.startUpdates(from: Date()) { [weak self] pedometerData, error in
            guard let pedometerData = pedometerData, error == nil else {
                print("Pedometer error: \(String(describing: error))")
                return
            }
            DispatchQueue.main.async {
                self?.currentPace = pedometerData.currentPace?.doubleValue ?? 0
                self?.currentStepCount = pedometerData.numberOfSteps.intValue
                self?.currentCadence = pedometerData.currentCadence?.doubleValue ?? 0
            }
        }
        
    }

    private func updateCountdown() {
        print("counting down")
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            stopCollectingData()
        }
    }

    func stopCollectingData() {
        print("stopped collecting data")
        stopCycle()
        if(numTrans < 100){
            numTrans += 1
            print("Num Trans: \(numTrans)")
            startCollectingData(for: currentActivity)
        }
    }
    
    func stopCycle() {
        motionManager.stopDeviceMotionUpdates()
        pedometer.stopUpdates()
        timer?.invalidate()
        timer = nil

        collectionTimer?.invalidate()
        collectionTimer = nil

        sendMotionDataToPhone()

        isCollecting = false
        status = "Collection stopped"
        print("collection stopped")
    }

       // Send motion data to iPhone
       private func sendMotionDataToPhone() {
           print("sending data to iphone")
           guard session.isReachable else {
               print("iPhone is not reachable")
               return
           }
           let dataString = motionData.map { $0.csvString }.joined(separator: "\n")
           print(dataString)
           let activity = motionData.first?.activity ?? "Unknown"
           let context: [String: Any] = ["activity": activity, "data": dataString]
           print(context)
           
           session.transferUserInfo(["activity": currentActivity, "data": dataString])

       }
}

extension DataCollectionViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Watch: The session has completed activation.")
        }
    }
}
