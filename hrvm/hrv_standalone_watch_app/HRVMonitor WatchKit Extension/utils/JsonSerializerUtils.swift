//
//  JsonSerializerUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/23/22.
//

import Foundation

/// A utility class for serializing and deserializing Codable objects to/from JSON.
public class JsonSerializerUtils {
    
    // MARK: - Serialization Methods
    
    /// Serializes a Codable object to a JSON string.
    ///
    /// - Parameter data: The Codable object to be serialized.
    /// - Returns: A JSON string representation of the Codable object.
    public static func serialize<T: Codable>(data: T) -> String {
        do {
            let encodedData = try JSONEncoder().encode(data)
            return String(data: encodedData, encoding: .utf8)!
        } catch {
            fatalError("Error occurred when encoding data object. Does it conform to Codable type?")
        }
    }
    
    // MARK: - Deserialization Methods
    
    /// Deserializes a JSON string to a Codable object.
    ///
    /// - Parameter jsonString: The JSON string to be deserialized.
    /// - Returns: A Codable object decoded from the JSON string.
    public static func deserialize<T: Codable>(jsonString: String) -> T {
        do {
            let dataFromJsonString = jsonString.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: dataFromJsonString)
        } catch {
            fatalError("Error occurred when decoding data object. Does it conform to Codable type?")
        }
    }
}
