import Foundation
import RxSwift

class EditTimeslotViewModel
{
    var timelineItemObservable: Observable<TimelineItem?>
    {
        return timelineItemVariable.asObservable()
    }

    let categoryProvider : CategoryProvider
    
    private let timeSlotService: TimeSlotService
    private let metricsService: MetricsService
    private let smartGuessService: SmartGuessService
    private let timeService: TimeService
    private let startDate: Date
    
    private let timelineItemVariable = Variable<TimelineItem?>(nil)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(startDate: Date,
         timelineItemsObservable: Observable<[TimelineItem]>,
         timeSlotService: TimeSlotService,
         metricsService: MetricsService,
         smartGuessService: SmartGuessService,
         timeService: TimeService)
    {
        self.startDate = startDate
        self.timeSlotService = timeSlotService
        self.metricsService = metricsService
        self.smartGuessService = smartGuessService
        self.timeService = timeService
        self.categoryProvider = DefaultCategoryProvider(timeSlotService: timeSlotService)
        
        timelineItemsObservable
            .map(filterSelectedElement(for: startDate))
            .bindTo(timelineItemVariable)
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Public methods
    func updateTimelineItem(_ timelineItem: TimelineItem, withCategory category: Category)
    {
        for timeSlot in timelineItem.timeSlots
        {
            updateTimeSlot(timeSlot, withCategory: category)
        }
    }
    
    // MARK: - Private methods
    private func updateTimeSlot(_ timeSlot: TimeSlot, withCategory category: Category)
    {
        let categoryWasOriginallySetByUser = timeSlot.categoryWasSetByUser
        
        timeSlotService.update(timeSlot: timeSlot, withCategory: category)
        metricsService.log(event: .timeSlotEditing(date: timeService.now, fromCategory: timeSlot.category, toCategory: category, duration: timeSlot.duration))
        
        let smartGuessId = timeSlot.smartGuessId
        if !categoryWasOriginallySetByUser && smartGuessId != nil
        {
            //Strike the smart guess if it was wrong
            smartGuessService.strike(withId: smartGuessId!)
        }
        else if smartGuessId == nil, let location = timeSlot.location
        {
            smartGuessService.add(withCategory: category, location: location)
        }
    }
    
    private func filterSelectedElement(for date: Date) -> ([TimelineItem]) -> TimelineItem?
    {
        return { timelineItems in
            timelineItems.filter({ $0.startTime == date }).first
        }
    }
}
