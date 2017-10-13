import UIKit
import RxSwift

class TimelinePresenter : NSObject
{
    private weak var viewController : TimelineViewController!
    private let viewModelLocator : ViewModelLocator
    fileprivate var padding : ContainerPadding?
    fileprivate let swipeInteractionController = SwipeInteractionController()
    
    private init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, andDate date: Date) -> TimelineViewController
    {
        let presenter = TimelinePresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getTimelineViewModel(forDate: date)
        
        let viewController = TimelineViewController(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func showEditTimeSlot(with startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>)
    {        
        let vc = EditTimeslotPresenter.create(with: viewModelLocator, startDate: startDate, timelineItemsObservable: timelineItemsObservable)
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = self
        viewController.present(vc, animated: true, completion: nil)
        
        swipeInteractionController.wireToViewController(viewController: vc)
    }
}

extension TimelinePresenter : UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
    {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting, containerPadding: padding)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return FromBottomTransition(presenting:true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return FromBottomTransition(presenting:false)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }
}

