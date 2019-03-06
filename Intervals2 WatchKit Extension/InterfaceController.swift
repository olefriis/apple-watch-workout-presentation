//
//  InterfaceController.swift
//  Intervals2 WatchKit Extension
//
//  Created by Ole Friis Østergaard on 06/03/2019.
//  Copyright © 2019 SpikeSoft. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {
    let healthStore = HKHealthStore()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let typesToShare: Set = [
            HKSampleType.workoutType()
        ]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        self.healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            print("Authorization requested: \(success)")
            if let e = error {
                print("Error: \(e.localizedDescription)")
            }
        }
    }
    
    @IBAction func startButtonTouched() {
        WKInterfaceController.reloadRootPageControllers(withNames: ["StopRun", "Run", "NowPlaying"], contexts: [], orientation: .horizontal, pageIndex: 1)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
