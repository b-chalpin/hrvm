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
        self.columnCount = Settings.HRVStoreSize + 1
        self.rowCount = 0
        self.epochs = 200
        self.eta = 0.01
        self.lam = 0.1
        self.weights = [Double](repeating: 0.0, count: self.columnCount)
    }
    public func test(X:[[Double]], y:[[Double]])
    {
        self.rowCount = X.count
        let X_bias = self.addBiasColumn(X: X)
        self.initWeights()
        let s = self.calculateSignal(X_bias: X_bias, y: y)
        let test = self.v_sigmoid(s: s)
    }
    
    public func fit(X:[[Double]], y:[[Double]], lam:Double?, eta:Double?, epochs:Int?)
    {
        if(epochs != nil){self.epochs = epochs!}
        if(eta != nil){self.eta = eta!}
        if(lam != nil){self.lam = lam!}
            
        self.rowCount = X.count
        let X_bias = self.addBiasColumn(X: X)
        self.initWeights()
        
        while(self.epochs > 0)
        {
            let s = self.calculateSignal(X_bias: X_bias, y: y)
            self.epochs -= 1
        }
        
    }
    
    public func predict(X:[Double])
    {
        
    }
    
    public func error(X:[Double], y:[Double])
    {
        
    }
    
    private func updateWeights()
    {
        
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
        let randomNums = (0..<self.columnCount).map{ _ in Double.random(in: 1.0 ... Double(self.rowCount)) }
        let scalar = (1 / Double(self.rowCount)).squareRoot()
        var results:[Double]
        
        results = vDSP.multiply(scalar, randomNums)
        self.weights = results
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
    
    private func v_sigmoid(s:[Double]) -> [Double]
    {
        let negSignal = vDSP.multiply(-1.0, s)
        let ones = Array(repeating: 1.0, count: self.rowCount)
        var results = Array(repeating: 0.0, count: self.rowCount)
        
        vvexp(&results, negSignal, [Int32(2)])
        results = vDSP.add(1.0, results)
        results = vDSP.divide(ones, results)
        
        return results
    }
}
