//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
/*
ThreatDetector is a singleton class that encapsulates the functionality to detect and acknowledge
potential HRV stress events. It uses the logistic regression algorithm (LogisticRegression class)
to make dynamic predictions if there are enough stress events detected in the LRDataStore object.

It contains methods to check for threats (checkHrvForThreat),
acknowledge threats (acknowledgeThreat),
generate labels for LR, and switch between prediction modes (checkThreatMode).

The ThreatDetectorStatus enum is used to keep track of the prediction mode (static or dynamic) and the ThreatDetector
class is an ObservableObject to make sure that changes to threatAcknowledged are properly published.

The storageService object is used to interact with a persistent storage mechanism
(LRDataStore object) that stores the HRV data and predicted labels.
*/
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
        
        if !self.dataStore.dataItems.isEmpty {
            let samples = self.dataStore.dataItems.map({ $0.sample })
            let labels = self.dataStore.dataItems.map({ $0.isStressed })
            let error = self.lrModel.error(X: samples, y: labels)
            
            // append our new data store sample and label with the error
            self.dataStore.add(samples: newSamples, labels: newLabels, errors: [error], feedback: feedback)
        } else {
            // append our new data store sample and label without the error
            self.dataStore.add(samples: newSamples, labels: newLabels, errors: nil, feedback: feedback)
        }
        
        print("FEEDBACK: \(feedback) - Threat acked")
        self.threatAcknowledged = true
        
        // check if we can start using dynamic prediction; if our stress count is larger than our minimum, we will switch to dynamic mode
        self.checkThreatMode()
        
        if (self.predictorMode == ._dynamic) {
            // train model with new user feedback
            self.fit_dynamic()
            
            // persist new trained weights to storage
            self.storageService.saveLRWeights(lrWeights: self.lrModel.weights)
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
        self.lrModel.fit(samples: self.dataStore.dataItems.map({ $0.sample }), labels: self.dataStore.dataItems.map({ $0.isStressed }))
    }
    
    // returns true for danger; false otherwise
    private func predict(predictionSet: [HrvItem]) -> Bool {
        if (self.predictorMode == ._static) {
            return self.predict_static(predictionSet: predictionSet)
        }
        return false
    }
    
    // static prediction method; compare latest HRV to a threshold value
    private func predict_static(predictionSet: [HrvItem]) -> Bool {
        print("STATIC MODE - Prediction")
        
        return predictionSet.last!.RMSSD < Settings.StaticDangerThreshold
    }
    
//    // use the logistic regressor to predict
   private func predict_dynamic(predictionSet: [HrvItem]) -> Bool {
        print("DYNAMIC MODE - Prediction")
        // change to type double array to pass to predict
        let prediction = self.lrModel.predict(X: [predictionSet.map({ Double($0.RMSSD) })])

        // convert double array to double
        let predictionValue = prediction[0]

        return predictionValue > Settings.LrPredictionThreshold
    }
   }
