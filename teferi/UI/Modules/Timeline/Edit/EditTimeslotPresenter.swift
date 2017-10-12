import Foundation
import RxSwift

class EditTimeslotPresenter
{
    private weak var viewController : EditTimeslotViewController!
    private let viewModelLocator : ViewModelLocator
    
    init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>) -> EditTimeslotViewController
    {
        let presenter = EditTimeslotPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getEditTimeslotViewModel(for: startDate, timelineItemsObservable: timelineItemsObservable)
        
        let viewController = StoryboardScene.Main.instantiateEditTimeslot()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func dismiss()
    {
        viewController.dismiss(animated: true)
    }
}
