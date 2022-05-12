//
//  EventItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/12/22.
//

import Foundation

struct EventItem {
    public var hrv: HrvItem
    public var hrvStore: [HrvItem]
    public var stressed: Bool
}
