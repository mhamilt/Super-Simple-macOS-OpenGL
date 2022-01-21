// This can be used as a Stop clock.

import Cocoa
import OpenGL.GL3


class Clock {
    private static var kNanoSecondConvScale: Double = 1.0e-9
    private var machTimebaseInfoRatio: Double = 0
    private var startTime = 0.0

    init() {
        var timebaseInfo = mach_timebase_info_data_t()
        timebaseInfo.numer = 0
        timebaseInfo.denom = 0
        let err = mach_timebase_info(&timebaseInfo)
        if err != KERN_SUCCESS {
            Swift.print(">> ERROR: \(err) getting mach timebase info!")
        }
        else {
            let numer = Double(timebaseInfo.numer)
            let denom = Double(timebaseInfo.denom)
            
            // This gives the resolution
            machTimebaseInfoRatio = Clock.kNanoSecondConvScale * (numer/denom)
            startTime = Double(mach_absolute_time())        // in nano seconds
        }
    }

    // Return the elapsed time in seconds
    func timeElapsed() -> Double {
        let currentTime = Double(mach_absolute_time())      // in nano seconds
        let elapsedTime = currentTime - startTime           // in nano seconds
        return elapsedTime * machTimebaseInfoRatio          // in seconds
    }
}
