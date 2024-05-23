//
//  SportDetectionViewModel.swift
//  Real-time Sport Analyzer
//
//  Created by Anthony Sky Ng-Thow-Hing on 5/21/24.
//
import SwiftUI
import CoreML
import CoreMotion
import WatchConnectivity
import WatchKit


class SportDetectionViewModel: ObservableObject {
    @Published var currentPrediction: String = "Unknown"
    @Published var isDetecting: Bool = true

    private var model: SportClassifier?
    private let motionManager = CMMotionManager()
    private let pedometer = CMPedometer()
    private var timer: Timer?
    private var dataBuffer: [MotionDataModel] = []
    private var currentPace: Double = 0.0
    private var currentStepCount: Int = 0
    private var currentCadence: Double = 0.0

    init() {
        loadModel()
        startDetection()
    }

    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            model = try SportClassifier(configuration: config)
        } catch {
            print("Failed to load model: \(error)")
        }
    }

    func startDetection() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 50.0
            motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.current!) { [weak self] (data, error) in
                if let validData = data {
                    self?.dataBuffer.append(MotionDataModel(
                        activity: "Unknown",
                        accelX: validData.userAcceleration.x,
                        accelY: validData.userAcceleration.y,
                        accelZ: validData.userAcceleration.z,
                        gyroX: validData.rotationRate.x,
                        gyroY: validData.rotationRate.y,
                        gyroZ: validData.rotationRate.z,
                        magX: validData.magneticField.field.x,
                        magY: validData.magneticField.field.y,
                        magZ: validData.magneticField.field.z,
                        pace: self?.currentPace ?? 0,
                        stepCount: self?.currentStepCount ?? 0,
                        cadence: self?.currentCadence ?? 0
                    ))
                }
            }

            startPedometerUpdates()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.makePrediction()
            }
        }
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
    private func makePrediction() {
        guard let model = model, dataBuffer.count > 0 else { return }

        // Calculate statistics for the 1-second window
        let accelXStats = calculateStatistics(for: dataBuffer.map { $0.accelX })
        let accelYStats = calculateStatistics(for: dataBuffer.map { $0.accelY })
        let accelZStats = calculateStatistics(for: dataBuffer.map { $0.accelZ })
        let gyroXStats = calculateStatistics(for: dataBuffer.map { $0.gyroX })
        let gyroYStats = calculateStatistics(for: dataBuffer.map { $0.gyroY })
        let gyroZStats = calculateStatistics(for: dataBuffer.map { $0.gyroZ })
        let magXStats = calculateStatistics(for: dataBuffer.map { $0.magX })
        let magYStats = calculateStatistics(for: dataBuffer.map { $0.magY })
        let magZStats = calculateStatistics(for: dataBuffer.map { $0.magZ })
        let paceStats = calculateStatistics(for: dataBuffer.map { $0.pace })
        let stepCountStats = calculateStatistics(for: dataBuffer.map { Double($0.stepCount) })
        let cadenceStats = calculateStatistics(for: dataBuffer.map { $0.cadence })

        // Create the input vector
        let inputArray = try! MLMultiArray(shape: [48], dataType: .double)
        let stats = [
            accelXStats, accelYStats, accelZStats,
            gyroXStats, gyroYStats, gyroZStats,
            magXStats, magYStats, magZStats,
            paceStats, stepCountStats, cadenceStats
        ].flatMap { $0 }
        for (i, value) in stats.enumerated() {
            inputArray[i] = NSNumber(value: value)
        }

        let input = SportClassifierInput(input: inputArray)

        do {
            let prediction = try model.prediction(input: input)
            let oldPrediction = currentPrediction
            currentPrediction = prediction.classLabel == 1 ? "Basketball" : "Soccer"
            if currentPrediction != oldPrediction {
                DispatchQueue.main.async {
                    WKInterfaceDevice.current().play(.success)
                }
            }
        } catch {
            print("Prediction error: \(error)")
        }

        // Clear the buffer for the next second
        dataBuffer.removeAll()
    }

    private func provideHapticFeedback() {
        WKInterfaceDevice.current().play(.start)
    }
    
    private func calculateStatistics(for data: [Double]) -> [Double] {
        let mean = data.reduce(0, +) / Double(data.count)
        let stddev = sqrt(data.reduce(0, { $0 + pow($1 - mean, 2) }) / Double(data.count))
        let min = data.min() ?? 0
        let max = data.max() ?? 0
        return [mean, stddev, min, max]
    }
}
