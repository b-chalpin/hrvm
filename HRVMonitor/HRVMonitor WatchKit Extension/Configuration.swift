//
//  Configuration.swift
//  HRVMonitor WatchKit Extension
//
//  Created by Timoster the Gr9 on 3/15/22.
//
import Foundation

enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum API {
    static var baseURL: URL {
        return try! URL(string: "https://" + Configuration.value(for: "BASE_URL"))!
    }
}
