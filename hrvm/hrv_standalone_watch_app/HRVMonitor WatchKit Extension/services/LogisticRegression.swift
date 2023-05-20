/*
LogisticRegression.swift

This class implements logistic regression for binary classification. It provides methods for fitting a logistic regression model to training data, making predictions on new data, and calculating the error rate of the model. The class also includes methods for updating the weights of the logistic regression model during training, calculating the signal from the data and current model weights, initializing the model weights, and normalizing the data.

The class uses the Accelerate framework for matrix multiplication and element-wise operations. It includes methods for adding a bias column to the input data and applying the sigmoid function to the calculated signal. The class also includes configurable hyperparameters for the number of epochs, learning rate, and regularization.

Properties:
- weights: An array of doubles representing the current weights of the model.
- rowCount: An integer representing the number of rows in the input data.
- columnCount: An integer representing the number of columns in the input data.
- epochs: An integer representing the number of epochs to train the model.
- eta: A double representing the learning rate for the model.
- lam: A double representing the regularization parameter for the model.

Public Methods:
- init(): Initializes the model weights to zero and sets the hyperparameters to default values.
- fit(samples:labels:): Fits the logistic regression model to the input data and labels.
- predict(X:): Makes predictions on new data using the trained model.
- error(X:y:): Calculates the error rate of the model on the input data and labels.

Private Methods:
- updateWeights(X:y:signal:): Updates the weights of the model during training.
- calculateSignal(X:y:): Calculates the signal from the input data and current model weights.
- initWeights(): Initializes the model weights randomly.
- normalize_0_1(X:): Normalizes the input data to the range [0,1].
- addBiasColumn(X:): Adds a bias column to the input data.
- v_sigmoid(signal:rowCount:fit:): Applies the sigmoid function to the calculated signal.
*/

import Foundation
import Accelerate

public class LogisticRegression {
    var weights: [Double]
    var rowCount: Int
    var columnCount: Int
    
    var epochs: Int
    var eta: Double
    var lam: Double
    
    public init() {
        // Initializing weights to zero and setting the length of HRV store plus one to account for bias.
        self.columnCount = Settings.HRVStoreSize + 1
        self.rowCount = 0
        self.epochs = Settings.LrEpochs
        self.eta = Settings.LrLearningRate
        self.lam = Settings.LrLambda
        self.weights = [Double](repeating: 0.0, count: self.columnCount)
    }
    
    public func fit(samples: [[HrvItem]], labels: [Double]) {
        // Reset model weights
        self.weights = [Double](repeating: 0.0, count: self.columnCount)
        
        var X = samples.map { $0.map { $0.RMSSD } }
        let y = labels

        self.rowCount = X.count
        var epochs = self.rowCount / 4 // Set epochs to the number of samples
        if self.rowCount < 4 {
            epochs = 1
        }
        X = self.addBiasColumn(X: X)
        X = X.shuffled()
        let X_train = self.normalize_0_1(X: X.flatMap { $0 })
        
        while epochs > 0 {
            let signal = self.calculateSignal(X: X_train, y: y)
            self.updateWeights(X: X_train, y: y, signal: signal)
            epochs -= 1
        }
    }
    
    public func predict(X: [[Double]]) -> [Double] {
        
        var X_bias = X
        let rowCount = X_bias.count
        var columnCount = X_bias[0].count
        var samples = Array(repeating: 0.0, count: (X_bias.flatMap { $0 }.count))
        var results = Array(repeating: 0.0, count: rowCount)
        let weights = self.weights
        
        if columnCount == columnCount - 1 {
            X_bias = self.addBiasColumn(X: X)
            samples = self.normalize_0_1(X: X_bias.flatMap { $0 })
            columnCount = X_bias[0].count
        } else {
            samples = X_bias.flatMap { $0 }
        }
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(rowCount), vDSP_Length(1), vDSP_Length(columnCount))
        
        return self.v_sigmoid(signal: results, rowCount: rowCount, fit: false)
    }
    
    public func error(X: [[HrvItem]], y: [Double]) -> Double {
        let doubleSamples = X.map { $0.map { $0.RMSSD } }
        
        let predictions = self.predict(X: doubleSamples)
        
        var error = 0.0
        for i in 0...(predictions.count - 1) {
            if (predictions[i] > Settings.LrPredictionThreshold && y[i] == 0) ||
               (predictions[i] <= Settings.LrPredictionThreshold && y[i] == 1) {
                error += 1.0
            }
        }
        
        return (error / Double(predictions.count))
    }
    
    private func updateWeights(X: [Double], y: [Double], signal: [Double]) {
        
        let samples = X
        let labels = y
        let sigmoid = self.v_sigmoid(signal: signal, rowCount: self.rowCount, fit: true)
        let scalar = self.eta / Double(self.rowCount)
        let scalar2 = 1 - (2 * self.eta * self.lam / Double(self.rowCount))
        var weights = Array(repeating: 0.0, count: self.columnCount)
        
        let m1 = vDSP.multiply(labels, sigmoid)
        let m2 = vDSP.multiply(scalar2, self.weights)
        
        vDSP_mmulD(m1, 1, samples, 1, &weights, 1, vDSP_Length(1), vDSP_Length(self.columnCount), vDSP_Length(self.rowCount))
        
        let m3 = vDSP.multiply(scalar, weights)
        let m4 = vDSP.add(m3, m2)
        
        self.weights = m4
    }
    
    private func calculateSignal(X: [Double], y: [Double]) -> [Double] {
        
        let samples = X
        let labels = y
        let weights = self.weights
        var results = Array(repeating: 0.0, count: self.rowCount)
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(self.rowCount), vDSP_Length(1), vDSP_Length(self.columnCount))
        let signal = vDSP.multiply(labels, results)
        
        return signal
    }
    
    private func initWeights() {
        
        let randomNums = (0 ..< self.columnCount).map { _ in Double.random(in: 0.0 ... 1.0) }
        let lower = -(1 / Double(self.columnCount).squareRoot())
        let upper = 1 / Double(self.columnCount).squareRoot()
        var weights: [Double]
        
        weights = vDSP.add(lower, randomNums)
        weights = vDSP.multiply((upper - lower), weights)
        
        weights[0] = 1.0
        
        self.weights = weights
    }
    
    private func normalize_0_1(X: [Double]) -> [Double] {
        
        var x_min = 0.0
        var x_max = 0.0
        var X_norm = Array(repeating: 0.0, count: X.count)
        var i = 0
        
        for value in X {
            if value > x_max {
                x_max = value
            } else if value < x_min {
                x_min = value
            }
        }
        
        for value in X {
            X_norm[i] = (value - x_min) / (x_max - x_min)
            i += 1
        }
        
        return X_norm
    }
    
    private func addBiasColumn(X: [[Double]]) -> [[Double]] {
        
        // Tried to find a clean/fast way to do this with the Accelerate framework. Need to look into it more; this is pretty low cost for now though.
        var X_bias = X
        let rowCount = X_bias.count
        
        for i in 0 ..< rowCount {
            X_bias[i].insert(1.0, at: 0)
        }
        
        return X_bias
    }
    
    private func v_sigmoid(signal: [Double], rowCount: Int, fit: Bool) -> [Double] {
        
        var negSignal = signal
        var sigmoid = Array(repeating: 0.0, count: rowCount)
        let ones = Array(repeating: 1.0, count: rowCount)
        
        if fit {
            negSignal = vDSP.multiply(-1, signal)
        }
        
        vvexp(&sigmoid, negSignal, [Int32(rowCount)])
        
        let m1 = vDSP.add(1, sigmoid)
        let m2 = vDSP.divide(ones, m1)
        
        return m2
    }
}
