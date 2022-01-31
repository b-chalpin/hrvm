//
//  HRVProcessor.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import Foundation

class HRVProcessor
{
    let ENTRY_CAPACITY = 10
    
    var entries: HRVChain
    
    init()
    {
        entries = HRVChain(capacity: ENTRY_CAPACITY)
    }
    
    func add(bpm: Double)
    {
        entries.add(node: HRVChainNode(entry: HRVEntry(bpm: bpm)))
    }
}
