//
//  ExportedEntities.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 6/2/22.
//
import Foundation

public class ExportedEntities : Codable {
    var patientSettings: PatientSettings?
    var eventItems: [EventItem]?
    var lrWeights: [Double]?
    var lrDataStore: LRDataStore?
    var hrvReadings: [HrvItem]?
}
