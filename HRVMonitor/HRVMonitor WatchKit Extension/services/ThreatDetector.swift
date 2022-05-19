//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/15/22.
//

import Foundation

class ThreatDetector : ObservableObject {
    // singleton
    public static let shared: ThreatDetector = ThreatDetector()
    private let lrModel: LogisticRegression
    
    @Published var threatDetected: Bool = false
    @Published var threatAcknowledged: Bool = false
    
    public func checkHrvForThreat(hrvStore: [HrvItem]) {
        let predicitonSet = [hrvStore.map{$0.value}]
        
        if self.predict(predictionSet: predicitonSet) {
            threatDetected = true
        }
    }
    
    // returns true for danger; false otherwise
    private func predict(predictionSet: [[Double]]) -> Bool {
        let prediction = lrModel.predict(X: predictionSet)
        
        // change the constant 0.75 to an enviroment variable
        // decided on probability for danger threshold < 0.75 is just a placeholder
        if(prediction[0] < 0.75){
            return true
        }
        
        return false
    }
    
    public func fit() {
        // stubbed out for now
    }
    
    public func error() {
        // stubbed out for now
    }
    
    // this method changed to detect if the threat was actaully acknowledged or not. Also calls fit and passes current HrvStore.
    public func acknowledgeThreat(feedback: Bool, hrvStore: [HrvItem]) {
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
    }
    
    private func loadLRDataStore() {
        // will need to add more logic here for loading from storage module
        var dataStore = LRDataStore()
    }
    
    private func updateLRDataStore(samples: [[HrvItem]], labels: [Double]) {
        
    }
}
