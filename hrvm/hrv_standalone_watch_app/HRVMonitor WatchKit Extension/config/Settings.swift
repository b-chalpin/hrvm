//
//  Settings.swift
//  HRVMonitor
//
//  Created by Nick Adams on 3/18/22.
//

import Foundation

/// A struct that provides access to various settings used in the HRVMonitor app.
enum Settings {
    /// The threshold value for safe HRV.
    public static var SafeHRVThreshold: Double {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        } catch {
            return 50.0
        }
    }
    
    /// The threshold value for mood warning based on HRV.
    public static var MoodWarningHRVThreshold: Double {
        do {
            return try Configuration.value(key: "MOOD_WARNING_HRV_THRESHOLD")
        } catch {
            return 30.0
        }
    }
    
    /// The threshold value for mood danger based on HRV.
    public static var MoodDangerHRVThreshold: Double {
        do {
            return try Configuration.value(key: "MOOD_DANGER_HRV_THRESHOLD")
        } catch {
            return 20.0
        }
    }
    
    /// The interval in seconds for monitoring HRV.
    public static var HRVMonitorIntervalSec: Double {
        do {
            return try Configuration.value(key: "HRV_MONITOR_INTERVAL_SEC")
        } catch {
            return 5.0
        }
    }
    
    /// The window size for HR calculations.
    public static var HRWindowSize: Int {
        do {
            return try Configuration.value(key: "HR_WINDOW_SIZE")
        } catch {
            return 15
        }
    }
    
    /// The size of the HRV store.
    public static var HRVStoreSize: Int {
        do {
            return try Configuration.value(key: "HRV_STORE_SIZE")
        } catch {
            return 15
        }
    }
    
    /// Indicates whether the app is in demo mode.
    public static var DemoMode: Bool {
        do {
            return try Configuration.value(key: "DEMO_MODE")
        } catch {
            return false
        }
    }
    
    /// The delay in seconds for sending notifications.
    public static var NotificationDelaySec: Double {
        do {
            return try Configuration.value(key: "NOTIFICATION_DELAY_SEC")
        } catch {
            return 5.0
        }
    }
    
    /// The page size for stress events.
    public static var StressEventPageSize: Int {
        do {
            return try Configuration.value(key: "STRESS_EVENT_PAGE_SIZE")
        } catch {
            return 5
        }
    }
    
    /// The threshold value for LR prediction.
    public static var LrPredictionThreshold: Double {
        do {
            return try Configuration.value(key: "LR_PREDICTION_THRESHOLD")
        } catch {
            return 0.40
        }
    }
    
    /// The number of epochs for LR training.
    public static var LrEpochs: Int {
        do {
            return try Configuration.value(key: "LR_EPOCHS")
        } catch {
            return 5
        }
    }
    
    /// The learning rate for LR training.
    public static var LrLearningRate: Double {
        do {
            return try Configuration.value(key: "LR_LEARNING_RATE")
        } catch {
            return 0.01
        }
    }
    
    /// The lambda value for LR training.
    public static var LrLambda: Double {
        do {
            return try Configuration.value(key: "LR_LAMBDA")
        } catch {
            return 1.0
        }
    }
    
    /// The minimum count of stress events.
    public static var MinStressEventCount: Int {
        do {
            return try Configuration.value(key: "MIN_STRESS_EVENT_COUNT")
        } catch {
            return 5
        }
    }
    
    /// The danger threshold for static HRV.
    public static var StaticDangerThreshold: Double {
        do {
            return try Configuration.value(key: "STATIC_DANGER_THRESHOLD")
        } catch {
            return 30.0
        }
    }
}
