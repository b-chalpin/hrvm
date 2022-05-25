//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 3/15/22.
//

import Foundation

enum ThreatDetectorStatus {
    case _static
    case _dynamic // LR
}

class ThreatDetector : ObservableObject {
    // singleton
    public static let shared: ThreatDetector = ThreatDetector()
    
    private var storageService = StorageService.shared
    private let lrModel = LogisticRegression(dataStore: LRDataStore())
    private var predictorMode: ThreatDetectorStatus = ._static
    private var lrDataStore: LRDataStore
    
    @Published var threatDetected: Bool = false
    @Published var threatAcknowledged: Bool = false
    
    init() {
        self.lrDataStore = self.storageService.loadLRDataStore()
    }
    
    public func checkHrvForThreat(hrvStore: [HrvItem]) {
        if self.predict(predictionSet: hrvStore) {
            threatDetected = true
        }
    }
    
    // this method changed to detect if the threat was actaully acknowledged or not. Also calls fit and passes current HrvStore.
    public func acknowledgeThreat(feedback: Bool, hrvStore: [HrvItem]) {
        // persist updates data store to storage
        storageService.saveLRDataStore(datastore: self.lrModel.dataStore)
        
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
        
        let samples = [hrvStore]
        var labels = [Double](repeating: 0.0, count: samples.count)
        
        if feedback {
            labels = [Double](repeating: 1.0, count: samples.count)
        }
        
        if (self.predictorMode == ._static) {
            // train model with new user feedback
            self.fit(samples: samples, labels: labels)
            
            // persist new trained weights to storage
            storageService.saveLRWeights(lrWeights: self.lrModel.weights)
        }
    }
    
    private func fit(samples: [[HrvItem]], labels: [Double]) {
        self.lrModel.fit(samples: samples, labels: labels)
    }
    
    // returns true for danger; false otherwise
    private func predict(predictionSet: [HrvItem]) -> Bool {
        if (self.predictorMode == ._static) {
            return predict_static(predictionSet: predictionSet)
        }
        else {
            return predict_lr(predictionSet: predictionSet)
        }
    }
    
    // static prediction method; compare latest HRV to a threshold value
    private func predict_static(predictionSet: [HrvItem]) -> Bool {
        return predictionSet.last!.value < Settings.DangerHRVThreshold
    }
    
    // use the logistic regressor to predict
    private func predict_lr(predictionSet: [HrvItem]) -> Bool {
        let doublePredictionSet = [HrvMapUtils.mapHrvStoreToDoubleArray(hrvStore: predictionSet)] // lr needs a [[Double]]
        
        let prediction = lrModel.predict(X: doublePredictionSet)
        
        print("PREDICTION: \(prediction[0])") // debug
        
        return prediction[0] > Settings.PredictionThreshold
    }
    
    public func error() {
        // stubbed out for now
    }
}
