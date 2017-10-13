import Foundation
import CoreGraphics

extension TimelineItem
{
    var lineHeight: CGFloat
    {
        return calculatedLineHeight(for: duration)
    }
    
    var startTimeText: String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: startTime)
    }
    
    var endTimeText: String?
    {
        guard let endTime = endTime else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return formatter.string(from: endTime)
    }
    
    var slotTimeText: String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: startTime)
        
        if isLastInPastDay, let endTime = endTime {
            let endString = formatter.string(from: endTime)
            return startString + " - " + endString
        } else {
            return startString
        }
    }
    
    var slotStartAndStopTimeText: String
    {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let startString = formatter.string(from: startTime)
        
        if let endTime = endTime
        {
            let endString = formatter.string(from: endTime)
            return startString + " - " + endString
        }
        else
        {
            return startString
        }
    }
    
    var elapsedTimeText: String
    {
        return formatedElapsedTimeText(for: duration)
    }
    
    var slotDescriptionText: String
    {
        guard shouldDisplayCategoryName && category != .unknown else {
            return ""
        }

        return category.description
    }
    
    var activityTagText: String?
    {
        guard let firstActivity = timeSlots.first?.activity else { return nil }
        
        let groupActivity = timeSlots.dropFirst().reduce(firstActivity) { acc, timeSlot -> MotionEventType? in
            guard let acc = acc, let timeSlotActivity = timeSlot.activity, acc == timeSlotActivity else { return nil }
            return timeSlotActivity
        }
                
        if groupActivity == nil {
            switch category {
            case .commute:
                return category.description
            default:
                return nil
            }
        } else {
            switch groupActivity! {
            case .auto, .walk, .cycling, .run:
                return groupActivity!.rawValue.capitalized
            default:
                return nil
            }
        }
    }
}
