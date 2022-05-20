//
//  LogisticRegression.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Nick Adams on 4/18/22.
//

import Foundation
import Accelerate

public class LogisticRegression {
    let dataStore:LRDataStore
    var weights:[Double]
    var rowCount:Int
    var columnCount:Int
    
    var epochs:Int
    var eta:Double
    var lam:Double
    
    public init(dataStore: LRDataStore) {
        //Initializing weights to zero and to be length of HRV store plus one to account for bias.
        self.dataStore = dataStore
        self.columnCount = Settings.HRVStoreSize + 1
        self.rowCount = 0
        self.epochs = 10
        self.eta = 0.0001
        self.lam = 0.1
        self.weights = [Double](repeating: 0.0, count: self.columnCount)
    }
    
    public func fit(samples:[[HrvItem]], labels:[Double]) {
        
        self.dataStore.add(samples: samples, labels: labels)
        let X = self.dataStore.samples!.map{$0.map{$0.value}}
        let y = self.dataStore.labels!
        
        var epochs = self.dataStore.size
        self.rowCount = X.count
        let X_bias = self.addBiasColumn(X: X)
        let X_train = self.normalize_0_1(X: X_bias.flatMap{$0})
        //self.initWeights()
        
        while(epochs > 0)
        {
            let signal = self.calculateSignal(X: X_train, y: y)
            self.updateWeights(X: X_train, y: y, signal: signal)
            epochs -= 1
        }
        
    }
    
    public func predict(X:[[Double]]) -> [Double] {
        
        var X_bias = X
        let rowCount = X_bias.count
        var columnCount = X_bias[0].count
        var samples = Array(repeating: 0.0, count: (X_bias.flatMap{$0}.count))
        var results = Array(repeating: 0.0, count: rowCount)
        let weights = self.weights
        
        if(columnCount == columnCount - 1)
        {
            X_bias = self.addBiasColumn(X: X)
            samples = self.normalize_0_1(X: X_bias.flatMap{$0})
            columnCount = X_bias[0].count
        }
        else
        {
            samples = X_bias.flatMap{$0}
        }
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(rowCount), vDSP_Length(1), vDSP_Length(columnCount))
        
        return self.v_sigmoid(signal: results, rowCount: rowCount, fit: false)
    }
    
    public func error(X:[[Double]], y:[Double]) -> Double {
        
        let predictions = self.predict(X: X)
        
        var error = 0.0
        for i in 0...(predictions.count - 1)
        {
            if((predictions[i] > 0.5 && y[i] == 0) || (predictions[i] <= 0.5 && y[i] == 1))
            {
                error += 1.0
            }
        }
        
        return (error/Double(predictions.count))
    }
    
    private func updateWeights(X:[Double], y:[Double], signal:[Double]) {
        
        let samples = X
        let labels = y
        let sigmoid = self.v_sigmoid(signal: signal, rowCount: self.rowCount, fit: true)
        let scalar = self.eta/Double(self.rowCount)
        let scalar2 = 1 - (2 * self.eta * self.lam / Double(self.rowCount))
        var weights = Array(repeating: 0.0, count: self.columnCount)
        
        let m1 = vDSP.multiply(labels, sigmoid)
        let m2 = vDSP.multiply(scalar2, self.weights)
        
        vDSP_mmulD(m1, 1, samples, 1, &weights, 1, vDSP_Length(1), vDSP_Length(self.columnCount), vDSP_Length(self.rowCount))
        
        let m3 = vDSP.multiply(scalar, weights)
        let m4 = vDSP.add(m3, m2)
        
        self.weights = m4
    }
    
    private func calculateSignal(X:[Double], y:[Double]) -> [Double] {
        
        let samples = X
        let labels = y
        let weights = self.weights
        var results = Array(repeating: 0.0, count: self.rowCount)
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(self.rowCount), vDSP_Length(1), vDSP_Length(self.columnCount))
        let signal = vDSP.multiply(labels, results)
        
        return signal
    }
    
    private func initWeights() {
        
        let randomNums = (0..<self.columnCount).map{ _ in Double.random(in: 0.0 ... 1.0)}
        let lower = -(1 / Double(self.columnCount).squareRoot())
        let upper = 1 / Double(self.columnCount).squareRoot()
        var weights:[Double]
        
        weights = vDSP.add(lower, randomNums)
        weights = vDSP.multiply((upper - lower), weights)
        
        weights[0] = 1.0
        
        self.weights = weights
    }
    
    private func normalize_0_1(X:[Double]) -> [Double] {
        
        var x_min = 0.0
        var x_max = 0.0
        var X_norm = Array(repeating: 0.0, count: X.count)
        var i = 0
        
        for value in X
        {
            if(value > x_max)
            {
                x_max = value
            }
            else if(value < x_min)
            {
                x_min = value
            }
        }
        
        for value in X
        {
            X_norm[i] = (value - x_min)/(x_max - x_min)
            i += 1
        }
        
        return X_norm
    }
    
    private func addBiasColumn(X:[[Double]]) -> [[Double]] {
        
        //Tried to find a clean/fast way to do this with accelerate lib. Need to look into it more this is pretty low cost for now though.
        var X_bias = X
        let rowCount = X_bias.count
        
        for i in 0...(rowCount - 1)
        {
            X_bias[i].insert(1.0, at: 0)
        }
        
        return X_bias
    }
    
    private func v_sigmoid(signal:[Double], rowCount:Int, fit:Bool) -> [Double] {
        
        var negSignal = signal
        var sigmoid = Array(repeating: 0.0, count: rowCount)
        let ones = Array(repeating: 1.0, count: rowCount)
        
        if(fit)
        {
            negSignal = vDSP.multiply(-1, signal)
        }
        
        vvexp(&sigmoid, negSignal, [Int32(rowCount)])
        
        let m1 = vDSP.add(1, sigmoid)
        let m2 = vDSP.divide(ones, m1)
        
        return m2
    }
}

