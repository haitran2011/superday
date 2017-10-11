import Foundation

class EditTimeslotViewModel
{
    let timelineItem: TimelineItem
    let timeSlotService: TimeSlotService
    
    init(timelineItem: TimelineItem, timeSlotService: TimeSlotService)
    {
        self.timelineItem = timelineItem
        self.timeSlotService = timeSlotService
    }
}
