//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin/ Nick Adams on 3/15/22.
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
    private let lrModel = LogisticRegression()
    private var predictorMode: ThreatDetectorStatus = ._static
    private var dataStore: LRDataStore

    @Published var threatAcknowledged: Bool = false
    
    init() {
        self.dataStore = self.storageService.getLRDataStore()
        self.checkThreatMode()
        print(dataStore.error!, "\n")
        print(dataStore.labels!, "\n")
        print(dataStore.samples!)
    }
    
    public func checkHrvForThreat(hrvStore: [HrvItem]) -> Bool {
        return self.predict(predictionSet: hrvStore)
    }
    
    // for checking if we should switch threat mode in acknowledgeThreat but also when we initialize ThreatDetector
    private func checkThreatMode() {
        if (self.dataStore.stressCount > Settings.MinStressEventCount) {
            self.predictorMode = ._dynamic
        }
    }
    
    // this method changed to detect if the threat was actaully acknowledged or not. Also calls fit and passes current HrvStore.
    public func acknowledgeThreat(feedback: Bool, hrvStore: [HrvItem]) {
        let newSamples = [hrvStore]
        let newLabels = self.generateLabelForFeedback(feedback: feedback, samples: newSamples)
        
        // append our new data store sample and label
        self.dataStore.add(samples: newSamples, labels: newLabels, feedback: feedback)
       
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
        
        // check if we can start using dynamic prediction; if our stress count is larger than our minimum, we will switch to dynamic mode
        self.checkThreatMode()
        
        if (self.predictorMode == ._dynamic) {
            // train model with new user feedback
            self.fit_dynamic()
            
            // persist new trained weights to storage
            self.storageService.saveLRWeights(lrWeights: self.lrModel.weights)
            
            let error = self.lrModel.error(X: self.dataStore.samples!, y: self.dataStore.labels!)
            self.dataStore.addError(error: error)
            
            print("ERROR: \(error)")
        }
        
        // persist new error update to storage
        storageService.saveLRDataStore(datastore: self.dataStore)
    }
    
    private func generateLabelForFeedback(feedback: Bool, samples: [[HrvItem]]) -> [Double] {
        var labels = [Double](repeating: 0.0, count: samples.count)
        
        if feedback {
            labels = [Double](repeating: 1.0, count: samples.count)
        }
        
        return labels
    }
    
    // train the LR model on our current data store and labels
    private func fit_dynamic() {
        self.lrModel.fit(samples: self.dataStore.samples!, labels: self.dataStore.labels!)
    }
    
    // returns true for danger; false otherwise
    private func predict(predictionSet: [HrvItem]) -> Bool {
        if (self.predictorMode == ._static) {
            return self.predict_static(predictionSet: predictionSet)
        }
        else {
            return self.predict_dynamic(predictionSet: predictionSet)
        }
    }
    
    // static prediction method; compare latest HRV to a threshold value
    private func predict_static(predictionSet: [HrvItem]) -> Bool {
        print("STATIC MODE - Prediction")
        
        return predictionSet.last!.value < Settings.StaticDangerThreshold
    }
    
    // use the logistic regressor to predict
    private func predict_dynamic(predictionSet: [HrvItem]) -> Bool {
        let doublePredictionSet = [HrvMapUtils.mapHrvStoreToDoubleArray(hrvStore: predictionSet)] // lr needs a [[Double]]
        let prediction = self.lrModel.predict(X: doublePredictionSet)
        
        print("DYNAMIC MODE - Prediction: \(prediction[0])")
        
        return prediction[0] > Settings.LrPredictionThreshold
    }
}
