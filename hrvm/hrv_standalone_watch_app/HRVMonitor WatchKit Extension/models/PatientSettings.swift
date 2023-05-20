//
//  PatientSettings.swift
//  HRVMonitor WatchKit Extension
//
//  This Swift code file defines the `PatientSettings` struct for the HRVMonitor WatchKit Extension.
//  The `PatientSettings` struct represents the settings and information of a patient, including their age and sex.
//
//  Created by bchalpin on 5/20/22.
//

import Foundation

/// A data structure representing the settings and information of a patient.
public struct PatientSettings: Codable {
    /// The age of the patient.
    public var age: Int
    /// The sex of the patient.
    public var sex: String
}
