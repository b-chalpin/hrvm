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
    
    init() {
        self.lrModel = LogisticRegression(dataStore: LRDataStore())
        self.loadLRDataStore()
    }
    
    public func checkHrvForThreat(hrvStore: [HrvItem]) {
        let predicitonSet = [hrvStore.map{$0.value}]
        
        if self.predict(predictionSet: predicitonSet) {
            threatDetected = true
        }
    }
    
    // this method changed to detect if the threat was actaully acknowledged or not. Also calls fit and passes current HrvStore.
    public func acknowledgeThreat(feedback: Bool, hrvStore: [HrvItem]) {
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
        
        let samples = [hrvStore]
        var labels = [Double](repeating: 0.0, count: samples.count)
        
        if feedback {
            labels = [Double](repeating: 1.0, count: samples.count)
        }
        
        self.fit(samples: samples, labels: labels)
    }
    
    private func fit(samples: [[HrvItem]], labels: [Double]) {
        self.lrModel.fit(samples: samples, labels: labels)
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
    
    public func error() {
        // stubbed out for now
    }
    
    private func loadLRDataStore() {
        // will need to add more logic here for loading from storage module
        // get LRDataStore then lrModel.dataStore = dataStore
    }
    
    private func saveLRDataStore() {
        // this funciton will save lrModel.dataStore to storage module
    }
    
    private func loadWeights() {
        // this function will load weights from storage module then set lrModels weights
    }
    
    private func saveWeights() {
        // this function will save weights from lrModels to storage module
    }
}
