//
//  EventItem.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/12/22.
//

import Foundation

public struct EventItem: Identifiable, Hashable, Codable {
    public var id: UUID
    public var timestamp: Date
    public var hrv: HrvItem
    public var hrvStore: [HrvItem]
    public var stressed: Bool
}
