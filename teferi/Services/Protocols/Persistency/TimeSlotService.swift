import RxSwift

///Service that creates and updates TimeSlots
protocol TimeSlotService
{
    var timeSlotCreatedObservable : Observable<TimeSlot> { get }
    var timeSlotUpdatedObservable : Observable<TimeSlot> { get }

    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: Category, categoryWasSetByUser: Bool, tryUsingLatestLocation: Bool) -> TimeSlot?
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, category: Category, categoryWasSetByUser: Bool, location: Location?) -> TimeSlot?
    
    @discardableResult func addTimeSlot(withStartTime startTime: Date, smartGuess: SmartGuess, location: Location?) -> TimeSlot?
    
    @discardableResult func addTimeSlot(fromTemporaryTimeslot: TemporaryTimeSlot) -> TimeSlot?
    /**
     Gets TimeSlots for any given day.
     
     - Parameter day: The day used for filtering the TimeSlots.
     - Returns: The found TimeSlots for the day or an empty array if there are none.
     */
    func getTimeSlots(forDay day: Date) -> [TimeSlot]
    
    func getTimeSlots(sinceDaysAgo days: Int) -> [TimeSlot]
    
    func getTimeSlots(betweenDate firstDate: Date, andDate secondDate: Date) -> [TimeSlot]
    /**
     Changes the category of an existing TimeSlot.
     
     - Parameter timeSlot: The TimeSlots to be updated.
     
     - Parameter category: The new category of the TimeSlot.
     
     - Parameter setByUser: Indicates if the user initiated the action that changed the TimeSlot.
     */
    func update(timeSlots: [TimeSlot], withCategory category: Category)
    
    /**
     Gets last registered TimeSlot.
     
     - Returns: The last saved TimeSlot.
     */
    func getLast() -> TimeSlot?
    
    /**
    Calculates the duration of a TimeSlot
     
     - Parameter timeSlot: The TimeSlot to use in the calculation
     - Returns: The duration of a timeslot
    */
    func calculateDuration(ofTimeSlot timeSlot: TimeSlot) -> TimeInterval
}
