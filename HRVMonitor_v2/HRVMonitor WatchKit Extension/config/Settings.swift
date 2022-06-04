//  Created by Nick Adams on 3/18/22.
//

import Foundation

enum Settings {
    public static var SafeHRVThreshold: Double {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 50.0
        }
    }
    
    public static var MoodWarningHRVThreshold: Double {
        do {
            return try Configuration.value(key: "MOOD_WARNING_HRV_THRESHOLD")
        }
        catch {
            return 30.0
        }
    }
    
    public static var MoodDangerHRVThreshold: Double {
        do {
            return try Configuration.value(key: "MOOD_DANGER_HRV_THRESHOLD")
        }
        catch {
            return 20.0
        }
    }
    
    public static var HRVMonitorIntervalSec: Double {
        do {
            return try Configuration.value(key: "HRV_MONITOR_INTERVAL_SEC")
        }
        catch {
            return 5.0
        }
    }
    
    public static var HRWindowSize: Int {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        }
        catch {
            return 15
        }
    }
    
    public static var HRVStoreSize: Int {
        do {
            return try Configuration.value(key: "HRV_STORE_SIZE")
        }
        catch {
            return 15
        }
    }
    
    public static var DemoMode: Bool {
        do {
            return try Configuration.value(key: "DEMO_MODE")
        }
        catch {
            return false
        }
    }
    
    public static var NotificationDelaySec: Double {
        do {
            return try Configuration.value(key: "NOTIFICATION_DELAY_SEC")
        }
        catch {
            return 5.0
        }
    }
    
    public static var StressEventPageSize: Int {
        do {
            return try Configuration.value(key: "STRESS_EVENT_PAGE_SIZE")
        }
        catch {
            return 5
        }
    }
    
    public static var LrPredictionThreshold: Double {
        do {
            return try Configuration.value(key: "LR_PREDICTION_THRESHOLD")
        }
        catch {
            return 0.40
        }
    }
    
    public static var LrEpochs: Int {
        do {
            return try Configuration.value(key: "LR_EPOCHS")
        }
        catch {
            return 5
        }
    }
    
    public static var LrLearningRate: Double {
        do {
            return try Configuration.value(key: "LR_LEARNING_RATE")
        }
        catch {
            return 0.01
        }
    }
    
    public static var LrLambda: Double {
        do {
            return try Configuration.value(key: "LR_LAMBDA")
        }
        catch {
            return 1.0
        }
    }
    
    public static var MinStressEventCount: Int {
        do {
            return try Configuration.value(key: "MIN_STRESS_EVENT_COUNT")
        }
        catch {
            return 5
        }
    }
    
    public static var StaticDangerThreshold: Double {
        do {
            return try Configuration.value(key: "STATIC_DANGER_THRESHOLD")
        }
        catch {
            return 30.0
        }
    }
}
