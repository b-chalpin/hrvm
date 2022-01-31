//
//  HRVParser.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Trevor Morris on 14/10/2021.
//

import Foundation

class HRVParser
{
    private var heartRates : [String] = []
    private var readingIndex = 0
    
    init(fname: String)
    {
        if let path = Bundle.main.path(forResource: fname, ofType: "txt") {
            let contents = try! String(contentsOfFile: path, encoding: .utf8)
            self.heartRates = contents.components(separatedBy: .newlines)
        }
    }
    
    func readNextEntry() -> HRVEntry?
    {
        let hr = heartRates[readingIndex]
        readingIndex += 1
        
        let hrvEntry = HRVEntry(bpm: Double(hr)!)
        return hrvEntry
    }
}
