import UIKit

func calculatedLineHeight(for duration: TimeInterval) -> CGFloat
{
    let minutes = (duration > 1 ? duration : 1) / 60
    let height: Double
    let minHeight: Double = 16
    
    guard minutes > 0 else { return CGFloat(minHeight) }
    
    if minutes <= 60 {
        height = 8/(15*minutes) + 120/15
    } else {
        height = (480 + minutes) / 13.5
    }
    
    return CGFloat(max(height, minHeight))
}

func formatedElapsedTimeText(for duration: TimeInterval) -> String
{
    let hourMask = "%02d h %02d min"
    let minuteMask = "%02d min"
    
    let minutes = (Int(duration) / 60) % 60
    let hours = (Int(duration) / 3600)
    
    return hours > 0 ? String(format: hourMask, hours, minutes) : String(format: minuteMask, minutes)
}
