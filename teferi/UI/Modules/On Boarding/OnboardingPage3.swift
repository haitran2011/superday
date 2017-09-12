import UIKit
import RxSwift

class OnboardingPage3 : OnboardingPage
{
    private var disposeBag : DisposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder, nextButtonText: nil)
    }
    
    override func startAnimations()
    {
        viewModel.movedToForegroundObservable
            .subscribe(onNext: onMovedToForeground)
            .addDisposableTo(disposeBag)
        
        viewModel.locationAuthorizationChangedObservable
            .subscribe(onNext: finish)
            .addDisposableTo(disposeBag)
    }
    
    override func finish()
    {        
        onboardingPageViewController.goToNextPage(forceNext: true)
        disposeBag = DisposeBag()
    }
    
    func onMovedToForeground()
    {
        if onboardingPageViewController.isCurrent(page: self)
        {
            viewModel.requestLocationAuthorization()
        }
    }
}
