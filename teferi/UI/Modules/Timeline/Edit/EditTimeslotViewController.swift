import UIKit

class EditTimeslotViewController: UIViewController
{
    // MARK: Private Properties
    fileprivate var viewModel : EditTimeslotViewModel!
    fileprivate var presenter : EditTimeslotPresenter!
    @IBOutlet private weak var blurView : UIVisualEffectView!
    @IBOutlet private weak var shadowView : ShadowView!
    @IBOutlet private weak var tableView: UITableView!
    
    
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = UIColor(r: 242, g: 242, b: 242)
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: TimelineCell.cellIdentifier)
        
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 8)))
        headerView.backgroundColor = .clear
        tableView.tableHeaderView = headerView
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        tableView.tableFooterView = footerView
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

extension EditTimeslotViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.cellIdentifier, for: indexPath) as! TimelineCell
        cell.useType = .editTimeslot
        cell.timelineItem = viewModel.timelineItem
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        return cell
    }
}
