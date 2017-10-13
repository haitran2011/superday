import UIKit
import CoreGraphics
import SnapKit
import RxSwift
import RxCocoa

enum TimelineCellUseType
{
    case timeline
    case editTimeslot
}

///Cell that represents a TimeSlot in the timeline
class TimelineCell : UITableViewCell
{
    static let cellIdentifier = "timelineCell"

    // MARK: Public Properties
    var timelineItem: TimelineItem? = nil
    {
        didSet
        {
            configure()
        }
    }
    
    var useType: TimelineCellUseType = .timeline
    {
        didSet
        {
            if let tagLeadingSpaceConstraint = tagLeadingSpaceConstraint, let tagYAlignConstraint = tagYAlignConstraint
            {
                tagLeadingSpaceConstraint.isActive = useType == .timeline
                tagYAlignConstraint.isActive = useType == .timeline
                setNeedsLayout()
            }
        }
    }
    
    private(set) var disposeBag = DisposeBag()
    
    @IBOutlet private(set) weak var categoryCircle: UIView!
    
    // MARK: Private Properties
    private var currentIndex = 0
    
    @IBOutlet private weak var contentHolder: UIView!
    @IBOutlet private weak var lineView : LineView!
    @IBOutlet private weak var slotTime : UILabel!
    @IBOutlet private weak var elapsedTime : UILabel!
    @IBOutlet private weak var slotDescription : UILabel!
    @IBOutlet private weak var timeSlotDistanceConstraint : NSLayoutConstraint!
    @IBOutlet private weak var categoryIcon: UIImageView!
    @IBOutlet private weak var lineHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet private weak var tagLeadingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tagYAlignConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dotView : UIView!
    @IBOutlet private weak var activityTagView: ActivityTagView!
    
    private var lineFadeView : AutoResizingLayerView?
    
    // MARK: Public Methods
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func configure()
    {
        guard let timelineItem = timelineItem else { return }
        
        //Updates each one of the cell's components
        layoutLine(withItem: timelineItem)
        layoutSlotTime(withItem: timelineItem)
        layoutElapsedTimeLabel(withItem: timelineItem)
        layoutDescriptionLabel(withItem: timelineItem)
        layoutCategoryIcon(forCategory: timelineItem.category)
        setupActivityTag(withTagText: timelineItem.activityTagText)
    }
    
    func animateIntro()
    {
        categoryCircle.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(
            withDuration: 0.39,
            options: UIViewAnimationOptions.curveEaseInOut) {
                self.categoryCircle.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        contentHolder.alpha = 0
        contentHolder.transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(
            withDuration: 0.492,
            options: UIViewAnimationOptions.curveEaseInOut) {
                self.contentHolder.transform = CGAffineTransform.identity
                self.contentHolder.alpha = 1
        }
    }
    
    // MARK: Private Methods
    
    /// Updates the icon that indicates the slot's category
    private func layoutCategoryIcon(forCategory category: Category)
    {
        categoryCircle.backgroundColor = category.color
        let image = UIImage(asset: category.icon)!
        let icon = categoryIcon!
        icon.image = image
        icon.contentMode = .scaleAspectFit
    }
    
    /// Updates the label that displays the description and starting time of the slot
    private func layoutDescriptionLabel(withItem item: TimelineItem)
    {
        slotDescription.text = item.slotDescriptionText
        timeSlotDistanceConstraint.constant = item.slotDescriptionText.isEmpty ? 0 : 6
    }
    
    /// Updates the label that shows the time the TimeSlot was created
    private func layoutSlotTime(withItem timelineItem: TimelineItem)
    {

        slotTime.text = (useType == .editTimeslot) ?
            timelineItem.slotStartAndStopTimeText :
            timelineItem.slotTimeText

    }
    
    /// Updates the label that shows how long the slot lasted
    private func layoutElapsedTimeLabel(withItem item: TimelineItem)
    {
        elapsedTime.textColor = item.category.color
        elapsedTime.text = item.elapsedTimeText
    }
    
    /// Updates the line that displays shows how long the TimeSlot lasted
    private func layoutLine(withItem item: TimelineItem)
    {
        lineHeight.constant = item.lineHeight
        lineView.color = item.category.color
        lineView.collapsed = item.containsMultiple
        dotView.backgroundColor = item.category.color
        
        lineView.fading = useType == .timeline ? item.isLastInPastDay : false
        
        lineFadeView?.isHidden = !item.isLastInPastDay
        
        dotView.isHidden = !item.isRunning && !item.isLastInPastDay
        
        bottomMargin.constant = useType == .timeline ?
            (item.isRunning ? 20 : 0) :
            (timelineItem?.activityTagText != nil ? 30 : 20)
                
        lineView.layoutIfNeeded()
    }
    
    private func setupActivityTag(withTagText tagText: String?)
    {
        guard let tagText = tagText else {
            activityTagView.isHidden = true
            return
        }
        
        activityTagView.isHidden = false
        activityTagView.configure(name: tagText)
    }
    
    /// Configure the fade overlay
    private func fadeOverlay(startColor: UIColor, endColor: UIColor) -> CAGradientLayer
    {
        let fadeOverlay = CAGradientLayer()
        fadeOverlay.colors = [startColor.cgColor, endColor.cgColor]
        fadeOverlay.locations = [0.1]
        fadeOverlay.startPoint = CGPoint(x: 0.0, y: 1.0)
        fadeOverlay.endPoint = CGPoint(x: 0.0, y: 0.0)
        return fadeOverlay
    }
}
