import UIKit
import RxSwift

enum SectionType: Int
{
    case singleSlot
    case multipleSlots
    case categorySelection
    case time
    case map
    
    enum TimeRowType: Int
    {
        case start
        case end
    }
    
    enum CategorySelectionRowType: Int
    {
        case categoryDetail
        case categprySelection
    }
}

class EditTimeslotViewController: UIViewController
{
    // MARK: Private Properties
    fileprivate var viewModel : EditTimeslotViewModel!
    fileprivate var presenter : EditTimeslotPresenter!
    fileprivate let disposeBag = DisposeBag()
    @IBOutlet private weak var blurView : UIVisualEffectView!
    @IBOutlet private weak var shadowView : ShadowView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    fileprivate var timelineItem : TimelineItem!
    {
        didSet
        {
            guard let tableView = self.tableView else { return }

            tableView.reloadSections([SectionType.singleSlot.rawValue, SectionType.multipleSlots.rawValue, SectionType.time.rawValue, SectionType.map.rawValue], animationStyle: .fade)
            tableView.reloadRows(at: [IndexPath(row: SectionType.CategorySelectionRowType.categoryDetail.rawValue, section: SectionType.categorySelection.rawValue)], with: .fade)
        }
    }
    fileprivate var isShowingCategorySelection = false
    {
        didSet
        {
            guard let tableView = self.tableView else { return }
            tableView.reloadSections([SectionType.categorySelection.rawValue], animationStyle: .fade)
        }
    }
    fileprivate var isMultiSlotItem : Bool {return timelineItem.timeSlots.count > 1 }
    
    // MARK: - Init
    func inject(presenter: EditTimeslotPresenter, viewModel: EditTimeslotViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createBindings()
        
        containerView.backgroundColor = viewModel.isShowingSubSlot ? .white : .clear
        topConstraint.constant = viewModel.isShowingSubSlot ? 58 : 50
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = UIColor(r: 242, g: 242, b: 242)
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: TimelineCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "SimpleDetailCell", bundle: Bundle.main), forCellReuseIdentifier: SimpleDetailCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "CategorySelectionCell", bundle: Bundle.main), forCellReuseIdentifier: CategorySelectionCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "MapCell", bundle: Bundle.main), forCellReuseIdentifier: MapCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "MultiSlotHeaderCell", bundle: Bundle.main), forCellReuseIdentifier: MultiSlotHeaderCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "MiniTimeSlotCell", bundle: Bundle.main), forCellReuseIdentifier: MiniTimeSlotCell.cellIdentifier)
        
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 8)))
        headerView.backgroundColor = .clear
        tableView.tableHeaderView = headerView
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
    }
    
    func createBindings()
    {
        viewModel.timelineItemObservable
            .subscribe(onNext: { (item) in
                guard let item = item
                else
                {
                    if !self.viewModel.isShowingSubSlot
                    {
                        if let presentedViewController = self.presentedViewController
                        {
                            presentedViewController.dismiss(animated: true, completion: {
                                self.presenter.dismiss()
                            })
                        }
                        else
                        {
                            self.presenter.dismiss()
                        }
                    }
                    return

                }
                self.timelineItem = item
            })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        let frame = blurView.bounds
        
        let maskPath = UIBezierPath(roundedRect: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.frame = frame
        mask.path = maskPath.cgPath
        
        blurView.layer.mask = mask
    }
    
    // MARK: - Actions
    @IBAction func closeButtonAction(_ sender: UIButton)
    {
        self.presenter.dismiss()
    }
}

extension EditTimeslotViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return }
        switch sectionType {
        case .multipleSlots:
            
            if indexPath.row > 0
            {
                presenter.showEditSubTimeSlot(with: timelineItem.timeSlots[indexPath.row - 1].startTime,
                                              timelineItemsObservable: viewModel.timelineItemsObservable)
            }
            
        case .categorySelection:
            
            guard let categorySelectionRowType = SectionType.CategorySelectionRowType.init(rawValue: indexPath.row) else { return }
            switch categorySelectionRowType {
            case .categoryDetail:
                isShowingCategorySelection = !isShowingCategorySelection
            default:
                break
            }
            
        default:
            break
        }
    }
}

extension EditTimeslotViewController : UITableViewDataSource
{
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard let sectionType = SectionType(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .multipleSlots:
            return isMultiSlotItem ? timelineItem.timeSlots.count + 1 : 0
        case .singleSlot:
            return isMultiSlotItem ? 0 : 1
        case .categorySelection:
            return isShowingCategorySelection ? 2 : 1
        case .time:
            if isMultiSlotItem
            {
                return 0
            }
            else if timelineItem.isRunning
            {
                return 1
            }
            else
            {
                return 2
            }
        case .map:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let sectionType = SectionType(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch sectionType {
        case .multipleSlots:
            
            if indexPath.row == 0
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: MultiSlotHeaderCell.cellIdentifier, for: indexPath) as! MultiSlotHeaderCell
                cell.configure(timelineItem: timelineItem)
                setup(cell)
                removeSeparator(cell)
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: MiniTimeSlotCell.cellIdentifier, for: indexPath) as! MiniTimeSlotCell
                cell.configure(with: timelineItem.timeSlots[indexPath.row - 1], alternativeEndTime: viewModel.timeService.now)
                setup(cell)
                if indexPath.row != timelineItem.timeSlots.count
                {
                    removeSeparator(cell)
                }
                return cell
            }
            
        case .singleSlot:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.cellIdentifier, for: indexPath) as! TimelineCell
            cell.useType = .editTimeslot
            cell.timelineItem = timelineItem
            setup(cell)
            return cell
            
        case .categorySelection:
            
            guard let categorySelectionRowType = SectionType.CategorySelectionRowType.init(rawValue: indexPath.row) else { return UITableViewCell() }
            
            switch categorySelectionRowType {
            case .categoryDetail:
                let cell = tableView.dequeueReusableCell(withIdentifier: SimpleDetailCell.cellIdentifier, for: indexPath) as! SimpleDetailCell
                cell.show(title: L10n.editTimeSlotCategoryTitle, value: timelineItem.category.description)
                setup(cell)
                if isShowingCategorySelection { removeSeparator(cell) }
                return cell
            case .categprySelection:
                let cell = tableView.dequeueReusableCell(withIdentifier: CategorySelectionCell.cellIdentifier, for: indexPath) as! CategorySelectionCell
                cell.configure(with: viewModel.categoryProvider, timelineItem: timelineItem)
                
                cell.editView
                    .editEndedObservable
                    .subscribe(onNext: viewModel.updateTimelineItem)
                    .addDisposableTo(disposeBag)
                
                setup(cell)
                return cell
            }
            
        case .time:
            
            guard let timeRowType = SectionType.TimeRowType.init(rawValue: indexPath.row) else { return UITableViewCell() }

            let cell = tableView.dequeueReusableCell(withIdentifier: SimpleDetailCell.cellIdentifier, for: indexPath) as! SimpleDetailCell
            
            switch timeRowType {
            case .start:
                cell.show(title: L10n.editTimeSlotStartTitle, value: timelineItem.startTimeText)
            case .end:
                cell.show(title: L10n.editTimeSlotEndTitle, value: timelineItem.endTimeText)
            }
            
            setup(cell)
            return cell
            
        case .map:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MapCell.cellIdentifier, for: indexPath) as! MapCell
            cell.configure(with: timelineItem.timeSlots)
            setup(cell)
            removeSeparator(cell)
            return cell
        }
    }
    
    private func removeSeparator(_ cell: UITableViewCell)
    {
        cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
    }
    
    private func setup(_ cell: UITableViewCell)
    {
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
    }
}
