//
//  ExportedEntities.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the ExportedEntities class for the HRVMonitor WatchKit Extension.
//  The ExportedEntities class is a data structure that contains entities that can be exported
//  from the app, such as patient settings, event items, logistic regression weights, logistic
//  regression data store, and HRV readings. This structure is particularly useful for exporting
//  and sharing data outside of the app in a standardized format.
//
//  Created by bchalpin on 6/2/22.
//

import Foundation

/// A data structure that contains entities that can be exported from the app.
public class ExportedEntities : Codable {
    var patientSettings: PatientSettings?
    var eventItems: [EventItem]?
    var lrWeights: [Double]?
    var lrDataStore: LRDataStore?
    var hrvReadings: [HrvItem]?
}
