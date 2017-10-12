import Foundation

struct TimeSlot
{
    // MARK: Properties
    let startTime: Date
    let endTime: Date?
    let category: Category
    let smartGuessId : Int?
    let location: Location?
    let categoryWasSetByUser: Bool
    let activity: MotionEventType?
}

extension TimeSlot
{
    init(withStartTime startTime: Date, endTime: Date? = nil, category: Category, categoryWasSetByUser: Bool, location: Location? = nil)
    {
        self.startTime = startTime
        self.endTime = endTime
        self.category = category
        self.smartGuessId = nil
        self.location = location
        self.categoryWasSetByUser = categoryWasSetByUser
        self.activity = nil
    }
    
    init(withStartTime time: Date, endTime: Date? = nil, smartGuess: SmartGuess, location: Location?)
    {
        self.startTime = time
        self.endTime = endTime
        self.category = smartGuess.category
        self.smartGuessId = smartGuess.id
        self.location = location
        self.categoryWasSetByUser = false
        self.activity = nil
    }
}

extension TimeSlot
{
    func withCategory(_ category: Category, setByUser: Bool? = nil) -> TimeSlot
    {
        return TimeSlot(startTime: self.startTime,
                        endTime: self.endTime,
                        category: category,
                        smartGuessId: self.smartGuessId,
                        location: self.location,
                        categoryWasSetByUser: setByUser ?? self.categoryWasSetByUser,
                        activity: self.activity)
    }
    
    func withEndDate( _ endDate: Date) -> TimeSlot
    {
        return TimeSlot(
            startTime: self.startTime,
            endTime: endDate,
            category: self.category,
            smartGuessId: self.smartGuessId,
            location: self.location,
            categoryWasSetByUser: self.categoryWasSetByUser,
            activity: self.activity)
    }
}

extension TimeSlot
{
    var duration: Double?
    {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}
