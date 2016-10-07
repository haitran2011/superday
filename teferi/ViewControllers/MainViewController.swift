import UIKit
import RxSwift
import MessageUI
import CoreMotion
import CoreGraphics
import QuartzCore
import CoreLocation
import SnapKit

class MainViewController : UIViewController, MFMailComposeViewControllerDelegate
{
    // MARK: Fields
    private var disposeBag : DisposeBag? = DisposeBag()
    private lazy var viewModel : MainViewModel =
    {
        return MainViewModel(persistencyService: self.persistencyService, metricsService: self.metricsService)
    }()
    
    private var pagerViewController : PagerViewController { return self.childViewControllers.last as! PagerViewController }
    
    //Dependencies
    private var metricsService : MetricsService!
    private var settingsService : SettingsService!
    private var locationService : LocationService!
    private var isEditingVariable : Variable<Bool>!
    private var persistencyService : PersistencyService!
    
    private var addButton : AddTimeSlotView!
    private var launchAnim : LaunchAnimationView!
    
    @IBOutlet private weak var icon : UIImageView!
    @IBOutlet private weak var logButton : UIButton!
    @IBOutlet private weak var titleLabel : UILabel!
    @IBOutlet private weak var debugView : DebugView!
    @IBOutlet private weak var calendarLabel : UIButton!
    
    func inject(_ locationService: LocationService, _ metricsService: MetricsService, _ persistencyService: PersistencyService, _ settingsService: SettingsService, _ isEditingVariable: Variable<Bool>) -> MainViewController
    {
        self.metricsService = metricsService
        self.locationService = locationService
        self.settingsService = settingsService
        self.isEditingVariable = isEditingVariable
        self.persistencyService = persistencyService
        
        return self
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Inject PagerViewController's dependencies
        pagerViewController.inject(metricsService, settingsService, persistencyService, isEditingVariable)
        
        //Debug screen
        debugView.isHidden = true
        
        //Launch animation
        self.launchAnim = LaunchAnimationView(frame: view.frame)
        self.view.addSubview(launchAnim)
        
        //Add button must be added like this due to .xib/.storyboard restrictions
        self.addButton = (Bundle.main.loadNibNamed("AddTimeSlotView", owner: self, options: nil)?.first) as? AddTimeSlotView
        self.view.addSubview(addButton!)
        self.addButton.snp.makeConstraints { make in
            
            make.height.equalTo(200)
            make.left.equalTo(self.view.snp.left)
            make.width.equalTo(self.view.snp.width)
            make.bottom.equalTo(self.view.snp.bottom)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //Refresh Dispose bag, if needed
        disposeBag = disposeBag ?? DisposeBag()
        
        //DEBUG SCREEN
        self.locationService
            .locationObservable
            .subscribe(onNext: debugView.onNewLocation)
            .addDisposableTo(disposeBag!)
        
        //Edit state
        self.isEditingVariable
            .asObservable()
            .subscribe(onNext: onEditChanged)
            .addDisposableTo(disposeBag!)
        
        //Category creation
        self.addButton!
            .categoryObservable
            .subscribe(onNext: onNewCategory)
            .addDisposableTo(disposeBag!)
        
        //Date updates for title label
        self.pagerViewController
            .dateObservable
            .subscribe(onNext: onDateChanged)
            .addDisposableTo(disposeBag!)
        
        //Small delay to give launch screen time to fade away
        Timer.schedule(withDelay: 0.1) { _ in
            self.launchAnim?.animate(onCompleted:
                {
                    self.launchAnim!.removeFromSuperview()
                    self.launchAnim = nil
                }
            )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        disposeBag = nil
        super.viewWillDisappear(animated)
    }
    
    // MARK: Actions
    @IBAction func onCalendarTouchUpInside()
    {
        let today = Date().ignoreTimeComponents()
        
        guard viewModel.currentDate.ignoreTimeComponents() != today else { return }
        
        pagerViewController.setViewControllers(
            [ TimelineViewController(date: today,
                                     metricsService: metricsService,
                                     persistencyService: persistencyService,
                                     isEditingVariable: isEditingVariable) ],
            direction: .forward,
            animated: true,
            completion: nil)
        
        onDateChanged(date: today)
    }
    
    @IBAction func onSendLogButtonTouchUpInside()
    {   
        guard MFMailComposeViewController.canSendMail() else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "You need to set up an email account before sending emails.")
        }
        
        guard let baseURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
        }
        
        let fileURL = baseURL.appendingPathComponent("swiftybeaver.log", isDirectory: false)
        
        guard let fileData = try? Data(contentsOf: fileURL) else
        {
            return showAlert(withTitle: "Something went wrong :(", message: "We are unable to find the log file.")
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject("Superday tracking log")
        mailComposer.setMessageBody("The log is attached.", isHTML: false)
        mailComposer.setToRecipients(["paul@toggl.com", "william@toggl.com"])
        mailComposer.addAttachmentData(fileData, mimeType: "text/plain", fileName: "superday.log")
        
        self.present(mailComposer, animated: true, completion: nil)
    }
    
    @IBAction func onDebugButtonTouchUpInside()
    {
        debugView.isHidden = !debugView.isHidden
    }
    
    // MARK: MFMailComposeViewControllerDelegate implementation
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Methods
    private func onDateChanged(date: Date)
    {
        viewModel.currentDate = date
        titleLabel.text = viewModel.title
        
        let today = Date().ignoreTimeComponents()
        let isToday = today == date.ignoreTimeComponents()
        let scale = CGFloat(isToday ? 1 : 0)
        
        self.addButton!.isAdding = false
        self.addButton!.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    private func onNewCategory(category: Category)
    {
        viewModel.addNewSlot(withCategory: category)
    }
    
    private func onEditChanged(_ isEditing: Bool)
    {
        let alpha = isEditing ? Constants.editingAlpha : 1
        
        icon.alpha = alpha
        logButton.alpha = alpha
        titleLabel.alpha = alpha
        
        logButton.isUserInteractionEnabled = !isEditing
        calendarLabel.isUserInteractionEnabled = !isEditing
    }
    
    func showAlert(withTitle title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
