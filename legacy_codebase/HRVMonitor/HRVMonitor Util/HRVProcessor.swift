//
//  HRVProcessor.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import Foundation

class HRVProcessor
{
    let ENTRY_CAPACITY = 15
    
    var entries: HRVChain
    var outlierData : Bool = false
    
    // NOTE: Not sure if this is the best place for these vars to compute outliers
    var currentMean : Float = -1
    var currentVariance : Float = -1
    private var numSamples : Int = 0
    
    init()
    {
        entries = HRVChain(capacity: ENTRY_CAPACITY)
    }
    
    func add(entry: HRVEntry)
    {
        entries.add(node: HRVChainNode(entry: entry))
    }
    
    func printEvery()
    {
        //print("--------------------------")
        
        var currentNode = entries.head
        while currentNode != nil {
            //print(currentNode!.entry.bpm)
            currentNode = currentNode!.getNext()
        }
    }
    
    func calcCurrentHRV() -> Double
    {
        var number: [Double] = []
        var currentNode = entries.head
        while currentNode != nil {
            number.append(currentNode!.entry.bpm)
            currentNode = currentNode!.getNext()
        }
        
        let calculatedHRV = calculate(number: number)
        
        outlierData = false
        if !calculatedHRV.isNaN {
            // NOTE: this is where updating the outlier algorithm will occur
            // SEE: https://towardsdatascience.com/easy-outlier-detection-in-data-streams-3089bfefe528
            let oldMean = currentMean
            if currentMean == -1 {
                currentMean = Float(calculatedHRV)
            }
            else {
                currentMean = currentMean * Float(numSamples) + Float(calculatedHRV)
                currentMean /= Float(numSamples + 1)
            }
            
            if currentVariance == -1 {
                currentVariance = 0         // It should be (calculatedHRV - currentMean)^2, but we both know it's just gonna be 0
            }
            else {
                let oldVariance = currentVariance
                currentVariance = Float(numSamples) * (oldVariance + powf(oldMean, 2)) + powf(Float(calculatedHRV), 2)
                currentVariance /= Float(numSamples + 1)
                currentVariance -= powf(currentMean, 2)
            }
            
            numSamples += 1
            
            // Check if outlier, and then print if so
            let normalizedOutlierValue = (Float(calculatedHRV) - currentMean) / sqrtf(currentVariance)
            print("\tNOV: " + String(normalizedOutlierValue))
            if normalizedOutlierValue < -4 {//-3 {// || normalizedOutlierValue > 3 {
                //print("\t\tHey, there's an outlier!!!!!")
                
                // Record that there is a lower outlier
                outlierData = true
            }
        }
        
        return calculatedHRV
    }
    
    private func calculate(number: [Double]) -> Double
    {
        //print("-------------------------\nSampled Heart Rates:")
        var arr:[Double] = []
        for num in number
        {
            //print("\t" + String(num))
            let total = 60000.0 / num
            arr.append(total)
        }
        let hrv = calculateSD(arr: arr)
        print("Calculated HRV: " + String(hrv))
        return hrv
    }
    
    private func calculateSD(arr : [Double]) -> Double
    {
        let length = Double(arr.count)
        let avg = arr.reduce( 0, {$0 + $1}) / length
        let sumOfSqaured = arr.map { pow( $0 - avg, 2.0)}.reduce(0, {$0 + $1})
        
        return sqrt(sumOfSqaured / (length - 1.0))
    }
}
