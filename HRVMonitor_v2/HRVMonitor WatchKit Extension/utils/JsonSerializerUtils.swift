//
//  JsonSerializerUtils.swift
//  HRVMonitor WatchKit Extension
//
//  Created by bchalpin on 5/23/22.
//

import Foundation

public class JsonSerializerUtils {
    public static func serialize<T:Codable>(data: T) -> String {
        do {
            let encodedData = try JSONEncoder().encode(data)
            return String(data: encodedData, encoding: .utf8)!
        }
        catch {
            fatalError("Error occurred when encoding data object. Does it conform to Codable type?")
        }
    }
    
    public static func deserialize<T:Codable>(jsonString: String) -> T {
        do {
            let dataFromJsonString = jsonString.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: dataFromJsonString)
        }
        catch {
            fatalError("Error occurred when decoding data object. Does it conform to Codable type?")
        }
    }
}
