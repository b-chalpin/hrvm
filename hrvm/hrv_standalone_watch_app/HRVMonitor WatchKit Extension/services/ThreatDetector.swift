//
//  ThreatDetector.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin/ Nick Adams on 3/15/22.
//

import Foundation

/// Represents the status of the threat detector.
enum ThreatDetectorStatus {
    case _static
    case _dynamic // LR
}

/// A singleton class that encapsulates the functionality to detect and acknowledge potential HRV stress events.
/// It uses the logistic regression algorithm (LogisticRegression class) to make dynamic predictions if there are enough stress events detected in the LRDataStore object.
/// The class contains methods to check for threats (checkHrvForThreat), acknowledge threats (acknowledgeThreat), generate labels for LR, and switch between prediction modes (checkThreatMode).
/// The ThreatDetectorStatus enum is used to keep track of the prediction mode (static or dynamic).
/// The ThreatDetector class is an ObservableObject to ensure that changes to threatAcknowledged are properly published.
/// The storageService object is used to interact with a persistent storage mechanism (LRDataStore object) that stores the HRV data and predicted labels.
class ThreatDetector: ObservableObject {
    /// The shared instance of `ThreatDetector`.
    public static let shared: ThreatDetector = ThreatDetector()
    
    private var storageService = StorageService.shared
    private let lrModel = LogisticRegression()
    private var predictorMode: ThreatDetectorStatus = ._static
    private var dataStore: LRDataStore

    /// Indicates whether a threat is acknowledged or not.
    @Published var threatAcknowledged: Bool = false
    
    /// Initializes the ThreatDetector instance.
    init() {
        self.dataStore = self.storageService.getLRDataStore()
        self.checkThreatMode()
    }
    
    /// Checks the HRV data for potential threats.
    /// - Parameter hrvStore: Array of HrvItem representing the HRV data.
    /// - Returns: A boolean indicating whether a threat is detected.
    public func checkHrvForThreat(hrvStore: [HrvItem]) -> Bool {
        return self.predict(predictionSet: hrvStore)
    }
    
    // Checks if we should switch threat mode in acknowledgeThreat but also when we initialize ThreatDetector.
    private func checkThreatMode() {
        if self.dataStore.stressCount > Settings.MinStressEventCount {
            self.predictorMode = ._dynamic
        }
    }
    
    /// Acknowledges a potential threat and updates the LRDataStore with feedback.
    /// - Parameters:
    ///   - feedback: The feedback indicating whether the threat is acknowledged or not.
    ///   - hrvStore: Array of HrvItem representing the HRV data.
    public func acknowledgeThreat(feedback: Bool, hrvStore: [HrvItem]) {
        let newSamples = [hrvStore]
        let newLabels = self.generateLabelForFeedback(feedback: feedback, samples: newSamples)
        
        if !self.dataStore.dataItems.isEmpty {
            let samples = self.dataStore.dataItems.map { $0.sample }
            let labels = self.dataStore.dataItems.map { $0.isStressed }
            let error = self.lrModel.error(X: samples, y: labels)
            
            // Append our new data store sample and label with the error
            self.dataStore.add(samples: newSamples, labels: newLabels, errors: [error], feedback: feedback)
        } else {
            // Append our new data store sample and label without the error
            self.dataStore.add(samples: newSamples, labels: newLabels, errors: nil, feedback: feedback)
        }
        
        print("FEEDBACK: \(feedback) - Threat acknowledged")
        self.threatAcknowledged = true
        
        // Check if we can start using dynamic prediction; if our stress count is larger than our minimum, we will switch to dynamic mode
        self.checkThreatMode()
        
        if self.predictorMode == ._dynamic {
            // Train model with new user feedback
            self.fitDynamic()
            
            // Persist new trained weights to storage
            self.storageService.saveLRWeights(lrWeights: self.lrModel.weights)
        }
        
        // Persist new error update to storage
        storageService.saveLRDataStore(datastore: self.dataStore)
    }

    private func generateLabelForFeedback(feedback: Bool, samples: [[HrvItem]]) -> [Double] {
        var labels = [Double](repeating: 0.0, count: samples.count)
        
        if feedback {
            labels = [Double](repeating: 1.0, count: samples.count)
        }
        
        return labels
    }
    
    /// Trains the LR model on the current data store and labels.
    private func fitDynamic() {
        self.lrModel.fit(samples: self.dataStore.dataItems.map { $0.sample }, labels: self.dataStore.dataItems.map { $0.isStressed })
    }
    
    /// Makes a prediction based on the given prediction set.
    /// - Parameter predictionSet: Array of HrvItem representing the HRV data for prediction.
    /// - Returns: A boolean indicating the prediction result.
    private func predict(predictionSet: [HrvItem]) -> Bool {
        if self.predictorMode == ._static {
            return self.predictStatic(predictionSet: predictionSet)
        }
        return false
    }
    
    /// Makes a static prediction by comparing the latest HRV to a threshold value.
    /// - Parameter predictionSet: Array of HrvItem representing the HRV data for prediction.
    /// - Returns: A boolean indicating the prediction result.
    private func predictStatic(predictionSet: [HrvItem]) -> Bool {
        print("STATIC MODE - Prediction")
        
        return predictionSet.last!.RMSSD < Settings.StaticDangerThreshold
    }
    
    /// Makes a dynamic prediction using the logistic regressor.
    /// - Parameter predictionSet: Array of HrvItem representing the HRV data for prediction.
    /// - Returns: A boolean indicating the prediction result.
    private func predictDynamic(predictionSet: [HrvItem]) -> Bool {
        print("DYNAMIC MODE - Prediction")
        // Change to type double array to pass to predict
        let prediction = self.lrModel.predict(X: [predictionSet.map { Double($0.RMSSD) }])

        // Convert double array to double
        let predictionValue = prediction[0]

        return predictionValue > Settings.LrPredictionThreshold
    }
}
