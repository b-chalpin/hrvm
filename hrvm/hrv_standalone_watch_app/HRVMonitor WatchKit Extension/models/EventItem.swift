//
//  EventItem.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the `EventItem` struct for the HRVMonitor WatchKit Extension.
//  `EventItem` is a data structure that represents a stress event detected by the MonitorEngine.
//  Each `EventItem` includes an identifier, a timestamp, the latest HRV item, the HRV store
//  (collection of recent HRV items), and a flag indicating whether the user was stressed or not.
//
//  Created by bchalpin on 5/12/22.
//

import Foundation

/// A data structure that represents a stress event detected by the MonitorEngine.
public struct EventItem: Identifiable, Hashable, Codable {
    /// The unique identifier of the event.
    public var id: UUID
    /// The timestamp of when the event occurred.
    public var timestamp: Date
    /// The latest HRV item associated with the event.
    public var hrv: HrvItem
    /// The collection of recent HRV items.
    public var hrvStore: [HrvItem]
    /// A flag indicating whether the user was stressed or not.
    public var isStressed: Bool
    /// A flag indicating whether the user had a change in sitting/standing
    public var sitStandChange: Bool
}
