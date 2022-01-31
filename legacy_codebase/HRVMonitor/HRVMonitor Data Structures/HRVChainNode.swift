//
//  HRVChainNode.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import Foundation

class HRVChainNode
{
    var entry: HRVEntry
    var next: HRVChainNode?
    
    init(entry: HRVEntry)
    {
        self.entry = entry
    }
    
    func setNext(next: HRVChainNode)
    {
        self.next = next
    }
    
    func getNext() -> HRVChainNode?
    {
        return self.next
    }
}
