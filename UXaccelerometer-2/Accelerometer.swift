//
//  Accelerometer.swift
//  UXaccelerometer-2
//
//  Created by Анна Михалева on 27.03.2020.
//  Copyright © 2020 dasharedd. All rights reserved.
//

import Foundation
import CoreMotion

class Accelerometer {
    
    static let shared = Accelerometer()
    
    lazy var motion = CMMotionManager()
    var timer : Timer?
    
    var x : Double = 0.0
    var y : Double = 0.0
    var z : Double = 0.0
    
    var controller : DataTransfer? = nil

    private let interval = 0.1
    
    private init() { }
    
    func startAccelerometers() {
       if self.motion.isAccelerometerAvailable {
        self.motion.accelerometerUpdateInterval = self.interval
          self.motion.startAccelerometerUpdates()

          self.timer = Timer(fire: Date(), interval: self.interval,
                repeats: true, block: { (timer) in
             if let data = self.motion.accelerometerData {
                self.x = data.acceleration.x
                self.y = data.acceleration.y
                self.z = data.acceleration.z
                self.controller?.sendCoordinates()
             }
          })

        RunLoop.current.add(self.timer!, forMode: .default)
       }
    }
    
    func stopAccelerometer() {
        self.motion.stopAccelerometerUpdates()
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }
    
    func convertToString() -> String {
        /// TODO: should discuss format string with boys
        return "\(self.x) \n\(self.y) \n\(self.z)"
    }
    
    
}

protocol DataTransfer: class {
    func sendCoordinates()
}

