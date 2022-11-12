//
//  MotionCollectionManager.swift
//  Compete Watch App
//
//  Created by Gowtham Saravanan on 05/11/22.
//

import Foundation
import HealthKit
import CoreMotion

class MotionCollectionManager: NSObject, ObservableObject  {
    
    var healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var motion = CMMotionManager()
    var queue = OperationQueue()
    let date = Date()
    
    @Published var wcManager = WatchManager()
    @Published var isSessionRunning = false
    @Published var totaCount = 0
    
    var csvText = "time,gyroX,gyroY,gyroZ,accelerationX,accelerationY,accelerationZ\n"

    func requestAuthorization() {
        let types: Set = [
            HKQuantityType(.heartRate)
        ]
        
        healthStore.requestAuthorization(toShare: types, read: types) { success, error in
            if success {
                //start the session
            }
        }
    }
        
    func startSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .transition
        configuration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            session?.delegate = self
            session?.startActivity(with: Date())
            self.isSessionRunning = true
        } catch {
            print("error in starting in wokrout session")
        }
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 30.0
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical,
                                                 to: self.queue, withHandler: { [self] (data, error) in
                // Make sure the data is valid before accessing it.
                if let validData = data {
                    // Get the attitude relative to the magnetic north reference frame.
                    let gyroX = validData.rotationRate.x
                    let gyroY = validData.rotationRate.y
                    let gyroZ = validData.rotationRate.z
                    let accelerationX = validData.userAcceleration.x
                    let accelerationY = validData.userAcceleration.y
                    let accelerationZ = validData.userAcceleration.z
                    
                    // Use the motion data in your app.
                    let text = ("\(-date.timeIntervalSinceNow),\(gyroX),\(gyroY),\(gyroZ),\(accelerationX),\(accelerationY),\(accelerationZ)\n")
                    self.csvText.append(text)
                    //self.wcManager.sendData(toWatch: ["csvData" : text])
                }
            })
        }
        print("started")
    }
    
    func PauseSession() {
        self.motion.stopDeviceMotionUpdates()
        self.session?.pause()
        // wcManager.sendFile(toWatch: ["csvData":csvText])
        print("pause")
    }
    
    func endSession() {
        self.session?.end()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent("message.txt")
        do {
            try csvText.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
        wcManager.sendFile(atURL: url)
        totaCount += 1
        csvText = "time,gyroX,gyroY,gyroZ,accelerationX,accelerationY,accelerationZ\n"
        print("ended in watch")
        isSessionRunning = false
    }
    
    
}



extension MotionCollectionManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            if toState != .running {
                self.isSessionRunning = false
            } else {
                self.isSessionRunning = true
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
}
