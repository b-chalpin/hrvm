//
//  Configuration.swift
//  HRVMonitor
//
//  Created by Nick Adams on 3/15/22.
//

import Foundation

/// A utility class for accessing configuration values.
enum Configuration {
    /// An enumeration of errors that can occur during configuration value retrieval.
    enum Error: Swift.Error {
        case missingKey
        case invalidValue
    }

    /// Retrieves a configuration value for the specified key.
    /// - Parameters:
    ///   - key: The key for the configuration value.
    /// - Returns: The configuration value of type `T`.
    /// - Throws: An error of type `Configuration.Error` if the value is missing or invalid.
    static func value<T>(key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else {
                fallthrough
            }
            return value
        default:
            throw Error.invalidValue
        }
    }
}
