//
//  RunController.swift
//  Intervals2 WatchKit Extension
//
//  Created by Ole Friis Østergaard on 06/03/2019.
//  Copyright © 2019 SpikeSoft. All rights reserved.
//

import Foundation
import WatchKit
import HealthKit

class RunController: WKInterfaceController {
    var workoutSession: HKWorkoutSession!
    var workoutBuilder: HKLiveWorkoutBuilder!
    var healthStore = HKHealthStore()
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .running
        workoutConfiguration.locationType = .outdoor
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession.delegate = self
            workoutBuilder = workoutSession.associatedWorkoutBuilder()
            workoutBuilder.delegate = self
            let dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: workoutConfiguration)
            workoutBuilder.dataSource = dataSource
            
            let startDate = Date()
            workoutSession.startActivity(with: startDate)
            workoutBuilder.beginCollection(withStart: startDate, completion: { (success, error) in
                print("beginCollection: Success \(success) \(String(describing: error))")
                self.timer.start()
                // TODO: Handle error
            })
        } catch {
            // TODO: Handle error
            print("Error starting workout")
        }
    }

    @IBAction func stopButtonTouched() {
        let workoutEndDate = Date()
        workoutSession.end()
        workoutBuilder.endCollection(withEnd: workoutEndDate, completion: { (success, error) in
            print("endCollection: Success \(success) Error \(String(describing: error))")
            self.workoutBuilder.finishWorkout(completion: { (workout, error) in
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootControllers(withNames: ["Start"], contexts: [])
                }
            })
        })
    }
}

extension RunController: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }
}

extension RunController: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        if collectedTypes.contains(distanceType) {
            let updatedStatistics = workoutBuilder.statistics(for: distanceType)!
            let distance = updatedStatistics.sumQuantity()!
            DispatchQueue.main.async {
                self.distanceLabel.setText(distance.description)
            }
        }
    }
}
