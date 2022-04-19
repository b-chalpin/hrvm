//
//  LogisticRegression.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 4/18/22.
//

import Foundation
import Accelerate

public class LogisticRegression
{
    var weights:[Double]
    
    public init()
    {
        //Initializing weights to zero and to be length of HRV store plus one to account for bias.
        self.weights = [Double](repeating: 0, count: Settings.HRVStoreSize + 1)
    }
    
    public func fit(X:[[Double]], y:[[Double]], lam:Double = 0.1, eta:Double = 0.01, epochs:Int = 200)
    {
        var samples = X
        //Need to create variable n = rows and d = columns of sample matrix
        samples = self.addBiasColumn(X: samples)
        
        
        
    }
    
    private func addBiasColumn(X:[[Double]]) -> [[Double]]
    {
        //Need to change this to append an array of 1's size n to front of samples matrix
        var samples = X
        return samples
    }
    
    public func predict(X:[Double])
    {
        
    }
    
    public func error(X:[Double], y:[Double])
    {
        
    }
    
    private func sigmoid(s:Double)
    {
        
    }
}
