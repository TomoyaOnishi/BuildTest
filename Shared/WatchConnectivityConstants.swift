extension WatchConnectivityManager.MessageKey {
    
    // Workout
    static let workoutStart = WatchConnectivityManager.MessageKey("Workout.start")
    static let workoutStop = WatchConnectivityManager.MessageKey("Workout.stop")
    static let workoutError = WatchConnectivityManager.MessageKey("Workout.error")
    
    // HeartRate
    static let heartRateIntergerValue = WatchConnectivityManager.MessageKey("HeartRate.intergerValue")
    static let heartRateRecordDate = WatchConnectivityManager.MessageKey("HeartRate.recordDate")
    
    // Pedometer
    static let pedometerIntergerValue = WatchConnectivityManager.MessageKey("Pedometer.intergerValue")
    static let pedometerRecordDate = WatchConnectivityManager.MessageKey("Pedometer.recordDate")
    
}
