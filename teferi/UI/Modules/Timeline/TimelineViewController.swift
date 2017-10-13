import RxSwift
import RxCocoa
import UIKit
import CoreGraphics
import RxDataSources

protocol TimelineDelegate: class
{
    func didScroll(oldOffset: CGFloat, newOffset: CGFloat)
}

class TimelineViewController : UIViewController
{
    // MARK: Public Properties
    var date : Date { return self.viewModel.date }

    // MARK: Private Properties
    private let disposeBag = DisposeBag()
    fileprivate let viewModel : TimelineViewModel
    fileprivate let presenter : TimelinePresenter
    
    private var tableView : UITableView!
    
    private var willDisplayNewCell:Bool = false
    
    private var emptyStateView: EmptyStateView!
    private var voteView: TimelineVoteView!
    
    weak var delegate: TimelineDelegate?
    {
        didSet
        {
            let topInset = tableView.contentInset.top
            let offset = tableView.contentOffset.y
            delegate?.didScroll(oldOffset: offset + topInset, newOffset: offset + topInset)
        }
    }
    
    private let dataSource = TimelineDataSource()

    // MARK: Initializers
    init(presenter: TimelinePresenter, viewModel: TimelineViewModel)
    {
        self.presenter = presenter
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("NSCoder init is not supported for this ViewController")
    }
    
    // MARK: UIViewController lifecycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateView = EmptyStateView.fromNib()
        view.addSubview(emptyStateView!)
        emptyStateView!.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
        }
        emptyStateView?.isHidden = true

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.register(UINib.init(nibName: "TimelineCell", bundle: Bundle.main), forCellReuseIdentifier: TimelineCell.cellIdentifier)
        tableView.register(UINib.init(nibName: "ShortTimelineCell", bundle: Bundle.main), forCellReuseIdentifier: ShortTimelineCell.cellIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 34, left: 0, bottom: 120, right: 0)
        
        dataSource.configureCell = constructCell
        
        createBindings()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        if viewModel.canShowVotingUI()
        {
            showVottingUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if !viewModel.canShowVotingUI()
        {
            tableView.tableFooterView = nil
        }
    }

    // MARK: Private Methods
    
    private func createBindings()
    {
        viewModel.timelineItemsObservable
            .map({ [TimelineSection(items:$0)] })
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        viewModel.timelineItemsObservable
            .map{$0.count > 0}
            .bindTo(emptyStateView.rx.isHidden)
            .addDisposableTo(disposeBag)
        
        tableView.rx
            .modelSelected(TimelineItem.self)
            .subscribe(onNext: { (item) in
                self.presenter.showEditTimeSlot(with: item.startTime, timelineItemsObservable: self.viewModel.timelineItemsObservable)
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [unowned self] (cell, indexPath) in
                guard self.willDisplayNewCell && indexPath.row == self.tableView.numberOfRows(inSection: 0) - 1 else { return }
                
                (cell as! TimelineCell).animateIntro()
                self.willDisplayNewCell = false
            })
            .addDisposableTo(disposeBag)
        
        let oldOffset = tableView.rx.contentOffset.map({ $0.y })
        let newOffset = tableView.rx.contentOffset.skip(1).map({ $0.y })
        
        Observable<(CGFloat, CGFloat)>.zip(oldOffset, newOffset)
        { [unowned self] old, new -> (CGFloat, CGFloat) in
            // This closure prevents the header to change height when the scroll is bouncing
            
            let maxScroll = self.tableView.contentSize.height - self.tableView.frame.height + self.tableView.contentInset.bottom
            let minScroll = -self.tableView.contentInset.top
            
            if new < minScroll || old < minScroll { return (old, old) }
            if new > maxScroll || old > maxScroll { return (old, old) }
            
            return (old, new)
            }
            .subscribe(onNext: { [unowned self] (old, new) in
                let topInset = self.tableView.contentInset.top
                self.delegate?.didScroll(oldOffset: old + topInset, newOffset: new + topInset)
            })
            .addDisposableTo(disposeBag)
        
        viewModel.didBecomeActiveObservable
            .subscribe(onNext: { [unowned self] in
                if self.viewModel.canShowVotingUI()
                {
                    self.showVottingUI()
                }
            })
            .addDisposableTo(disposeBag)
        
        viewModel.dailyVotingNotificationObservable
            .subscribe(onNext: onNotificationOpen)
            .addDisposableTo(disposeBag)
        
        viewModel.lastSlotUpdateObservable
            .subscribe(onNext: reloadLastSlot)
            .addDisposableTo(disposeBag)
    }
    
    private func showVottingUI()
    {
        tableView.tableFooterView = nil
        
        voteView = TimelineVoteView.fromNib()
        
        tableView.tableFooterView = voteView
        
        voteView.setVoteObservable
            .subscribe(onNext: viewModel.setVote)
            .addDisposableTo(disposeBag)
    }
    
    private func onNotificationOpen(on date: Date)
    {
        guard
            date.ignoreTimeComponents() == viewModel.date.ignoreTimeComponents(),
            viewModel.canShowVotingUI()
        else { return }
        
        if tableView.tableFooterView == nil
        {
            showVottingUI()
        }
        
        tableView.reloadData()
        let bottomOffset = CGPoint(x: 0, y: tableView.contentSize.height + tableView.tableFooterView!.bounds.height - tableView.bounds.size.height)
        tableView.setContentOffset(bottomOffset, animated: true)
    }

    private func handleNewItem(_ items: [TimelineItem])
    {
        let numberOfItems = tableView.numberOfRows(inSection: 0)
        guard numberOfItems > 0, items.count == numberOfItems + 1 else { return }
        
        willDisplayNewCell = true
        let scrollIndexPath = IndexPath(row: numberOfItems - 1, section: 0)
        tableView.scrollToRow(at: scrollIndexPath, at: .bottom, animated: true)
    }
    
    private func constructCell(dataSource: TableViewSectionedDataSource<TimelineSection>, tableView: UITableView, indexPath: IndexPath, item:TimelineItem) -> UITableViewCell
    {
        if item.category == .commute {
         
            let cell = tableView.dequeueReusableCell(withIdentifier: ShortTimelineCell.cellIdentifier, for: indexPath) as! ShortTimelineCell
            cell.timelineItem = item
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.cellIdentifier, for: indexPath) as! TimelineCell
        cell.timelineItem = item
        cell.selectionStyle = .none
        return cell
    }
    
    private func buttonPosition(forCellIndex index: Int) -> CGPoint
    {
        guard let cell = tableView.cellForRow(at: IndexPath(item: index, section: 0)) as? TimelineCell else {
            return CGPoint.zero
        }
        
        return cell.categoryCircle.convert(cell.categoryCircle.center, to: view)
    }
    
    private func reloadLastSlot()
    {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        guard numberOfRows > 0 else { return }
        
        tableView.reloadRows(at: [IndexPath(row: numberOfRows - 1, section: 0)], with: .none)
    }
}

