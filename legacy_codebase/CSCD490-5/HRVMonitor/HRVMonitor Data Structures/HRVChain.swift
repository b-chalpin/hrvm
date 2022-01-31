//
//  HRVEntryChain.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 13/10/2021.
//

import Foundation

class HRVChain
{
    var capacity: Int
    var size: Int
    var head: HRVChainNode?
    var tail: HRVChainNode?
    
    init(capacity: Int)
    {
        self.capacity = capacity
        self.size = 0
    }
    
    func add(node: HRVChainNode)
    {
        if(self.head == nil)
        {
            self.head = node
            self.tail = node
            self.size += 1
        }
        else
        {
            if(self.size == capacity)
            {
                self.head = self.head?.getNext();
                self.size -= 1
            }
            
            addLast(node: node)
        }
    }
    
    private func addLast(node: HRVChainNode)
    {
        self.tail?.setNext(next: node)
        self.tail = node
        self.size += 1
    }
}
