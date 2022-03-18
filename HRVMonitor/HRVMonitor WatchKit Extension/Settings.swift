//  Created by Timoster the Gr9 on 3/18/22.
//

import Foundation

enum Settings {
    public static var SafeHRVThreshold: () -> Double = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 50.0
        }
    }
    
    public static var WarningHRVThreshold: () -> Double = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 30.0
        }
    }
    
    public static var DangerHRVThreshold: () -> Double = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 20.0
        }
    }
    
    public static var HRVMonitorIntervalSec: () -> Double = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 5.0
        }
    }
    
    public static var HRWindowSize: () -> Int = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 15
        }
    }
    
    public static var HRStoreSize: () -> Int = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 60
        }
    }
    
    public static var HRVStoreSize: () -> Int = {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 15
        }
    }
}
