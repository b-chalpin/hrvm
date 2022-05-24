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
    
    private var storageService = StorageService.shared
    
    private let lrModel: LogisticRegression
    
    @Published var threatDetected: Bool = false
    @Published var threatAcknowledged: Bool = false
    
    init() {
        let dataStore = self.storageService.loadLRDataStore()
        self.lrModel = LogisticRegression(dataStore: dataStore)
    }
    
    public func checkHrvForThreat(hrvStore: [HrvItem]) {
        let predicitionSet = [hrvStore.map { $0.value }]
        
        if self.predict(predictionSet: predicitionSet) {
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
        
        // train model with new user feedback
        self.fit(samples: samples, labels: labels)
    }
    
    private func fit(samples: [[HrvItem]], labels: [Double]) {
        self.lrModel.fit(samples: samples, labels: labels)
        
        // persist new trained weights to storage
        storageService.saveLRWeights(lrWeights: self.lrModel.weights)
        
        // persist updates data store to storage
        storageService.saveLRDataStore(datastore: self.lrModel.dataStore)
    }
    
    // returns true for danger; false otherwise
    private func predict(predictionSet: [[Double]]) -> Bool {
        if (Settings.StaticThreatDetector) {
            return predict_static(predictionSet: predictionSet)
        }
        else {
            return predict_lr(predictionSet: predictionSet)
        }
    }
    
    // static prediction method; compare latest HRV to a threshold value
    private func predict_static(predictionSet: [[Double]]) -> Bool {
        return predictionSet[0].last! < Settings.DangerHRVThreshold
    }
    
    // use the logistic regressor to predict
    private func predict_lr(predictionSet: [[Double]]) -> Bool {
        let prediction = lrModel.predict(X: predictionSet)
        
        print("PREDICTION: \(prediction[0])") // debug
        
        // change the constant 0.75 to an enviroment variable
        // decided on probability for danger threshold < 0.75 is just a placeholder
        if(prediction[0] > Settings.PredictionThreshold){
            return true
        }
        
        return false
    }
    
    public func error() {
        // stubbed out for now
    }
}
