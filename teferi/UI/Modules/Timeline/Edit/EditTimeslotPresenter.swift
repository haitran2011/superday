import Foundation
import RxSwift

class EditTimeslotPresenter: NSObject
{
    private weak var viewController : EditTimeslotViewController!
    private let viewModelLocator : ViewModelLocator
    fileprivate var padding : ContainerPadding?
    fileprivate let swipeInteractionController = SwipeInteractionController()
    
    init(viewModelLocator: ViewModelLocator)
    {
        self.viewModelLocator = viewModelLocator
    }
    
    static func create(with viewModelLocator: ViewModelLocator, startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>, isShowingSubSlot: Bool = false) -> EditTimeslotViewController
    {
        let presenter = EditTimeslotPresenter(viewModelLocator: viewModelLocator)
        let viewModel = viewModelLocator.getEditTimeslotViewModel(for: startDate, timelineItemsObservable: timelineItemsObservable, isShowingSubSlot: isShowingSubSlot)
        
        let viewController = StoryboardScene.Main.instantiateEditTimeslot()
        viewController.inject(presenter: presenter, viewModel: viewModel)
        presenter.viewController = viewController
        
        return viewController
    }
    
    func showEditSubTimeSlot(with startDate: Date, timelineItemsObservable: Observable<[TimelineItem]>)
    {
        let vc = EditTimeslotPresenter.create(with: viewModelLocator, startDate: startDate, timelineItemsObservable: timelineItemsObservable, isShowingSubSlot: true)
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = self
        viewController.present(vc, animated: true, completion: nil)
        
        swipeInteractionController.wireToViewController(viewController: vc)
    }
    
    func dismiss()
    {
        viewController.dismiss(animated: true)
    }
}

extension EditTimeslotPresenter : UIViewControllerTransitioningDelegate
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
