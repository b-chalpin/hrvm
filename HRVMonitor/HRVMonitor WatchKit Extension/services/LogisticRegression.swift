//
//  LogisticRegression.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 4/18/22.
//

import Foundation
import Accelerate
import HealthKit

public class LogisticRegression
{
    var weights:[Double]
    var rowCount:Int
    var columnCount:Int
    
    var epochs:Int
    var eta:Double
    var lam:Double
    
    public init()
    {
        //Initializing weights to zero and to be length of HRV store plus one to account for bias.
        self.columnCount = 10 + 1
        self.rowCount = 0
        self.epochs = 100
        self.eta = 0.001
        self.lam = 0.1
        self.weights = [Double](repeating: 1.0, count: self.columnCount)
    }
    
    public func test(X:[[Double]], y:[[Double]])
    {
        var epochs = self.epochs
        self.rowCount = X.count
        let X_bias = self.addBiasColumn(X: X)
        self.initWeights()
        print(" ")
        print("Init Weights: ", self.weights)
        
        while(epochs > 0)
        {
            let signal = self.calculateSignal(X_bias: X_bias, y: y)
            self.updateWeights(X: X_bias, y: y, signal: signal)
            
            if(epochs % 10 == 0)
            {
                print("Update: ", self.weights)
            }
            
            epochs -= 1
        }
        
    }
    
    public func fit(X:[[Double]], y:[[Double]], lam:Double?, eta:Double?, epochs:Int?)
    {
        if(epochs != nil){self.epochs = epochs!}
        if(eta != nil){self.eta = eta!}
        if(lam != nil){self.lam = lam!}
        
        var epochs = self.epochs
        self.rowCount = X.count
        let X_bias = self.addBiasColumn(X: X)
        self.initWeights()
        
        while(epochs > 0)
        {
            let signal = self.calculateSignal(X_bias: X_bias, y: y)
            self.updateWeights(X: X_bias, y: y, signal: signal)
            
            if(epochs % 10 == 0)
            {
                print("Update: ", self.weights)
            }
            
            epochs -= 1
        }
        
    }
    
    public func predict(X:[[Double]]) -> [Double]
    {
        var X_bias = X
        
        if(X[0].count == self.columnCount - 1)
        {
            X_bias = self.addBiasColumn(X: X)
        }
        
        let weights = self.weights.flatMap{$0}
        let samples = X_bias.flatMap{$0}
        var results = Array(repeating: 0.0, count: self.rowCount)
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(self.rowCount), vDSP_Length(1), vDSP_Length(self.columnCount))
        
        return self.v_sigmoid(signal: results)
    }
    
    public func error(X:[Double], y:[Double])
    {
        
    }
    
    private func updateWeights(X:[[Double]], y:[[Double]], signal:[Double])
    {
        let order = CblasRowMajor
        let transpose = CblasNoTrans
        let noTranspose = CblasTrans
        
        let samples = X.flatMap{$0}
        let labels = y.flatMap{$0}
        var weights = Array(repeating: 0.0, count: self.columnCount)
        
        let m1 = vDSP.multiply(labels, self.v_sigmoid(signal: signal))
        let m2 = vDSP.multiply( 1 - 2 * self.eta * self.lam / Double(self.rowCount), self.weights)
        
        cblas_dgemm(order, transpose, noTranspose, Int32(self.rowCount), Int32(self.columnCount), Int32(1), 1.0, m1, Int32(1), samples, Int32(self.columnCount), 1.0, &weights, Int32(self.columnCount))
        weights = vDSP.multiply((self.eta/Double(self.rowCount)), weights)
        weights = vDSP.add(weights, m2)
        
        self.weights = weights
    }
    
    private func calculateSignal(X_bias:[[Double]], y:[[Double]]) -> [Double]
    {
        let samples = X_bias.flatMap{$0}
        let labels = y.flatMap{$0}
        let weights = self.weights
        var results = Array(repeating: 0.0, count: self.rowCount)
        
        vDSP_mmulD(samples, 1, weights, 1, &results, 1, vDSP_Length(self.rowCount), vDSP_Length(1), vDSP_Length(self.columnCount))
        let signal = vDSP.multiply(labels, results)
        
        return signal
    }
    
    private func initWeights()
    {
        let randomNums = (0..<self.columnCount).map{ _ in Double.random(in: 0.0 ... 1.0)}
        let lower = -(1 / Double(self.columnCount).squareRoot())
        let upper = 1 / Double(self.columnCount).squareRoot()
        var weights:[Double]
        
        weights = vDSP.add(lower, randomNums)
        weights = vDSP.multiply((upper - lower), weights)
        
        weights[0] = 1.0
        
        self.weights = weights
    }
    
    private func addBiasColumn(X:[[Double]]) -> [[Double]]
    {
        //Tried to find a clean/fast way to do this with accelerate lib. Need to look into it more this is pretty low cost for now though.
        var X_bias = X
        
        for i in 0...(self.rowCount - 1)
        {
            X_bias[i].insert(1.0, at: 0)
        }
        
        return X_bias
    }
    
    private func v_sigmoid(signal:[Double]) -> [Double]
    {
        let negSignal = vDSP.multiply(-1.0, signal)
        let ones = Array(repeating: 1.0, count: self.rowCount)
        var sigmoid = Array(repeating: 0.0, count: self.rowCount)
        
        vvexp(&sigmoid, negSignal, [Int32(self.rowCount)])
        sigmoid = vDSP.add(1.0, sigmoid)
        sigmoid = vDSP.divide(ones, sigmoid)
        
        return sigmoid
    }
}
