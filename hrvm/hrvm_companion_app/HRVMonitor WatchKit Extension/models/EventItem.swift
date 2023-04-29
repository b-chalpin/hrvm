//
//  EventItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the EventItem struct for the HRVMonitor WatchKit Extension.
//  EventItem is a data structure that represents a stress event detected by the MonitorEngine.
//  Each EventItem includes an identifier, a timestamp, the latest HRV item, the HRV store
//  (collection of recent HRV items), and a flag indicating whether the user was stressed or not.
//
//  Created by bchalpin on 5/12/22.
//

import Foundation

public struct EventItem: Identifiable, Hashable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var hrv: HrvItem
    public var hrvStore: [HrvItem]
    public var isStressed: Bool
    public var sitStandChange: Bool
}
