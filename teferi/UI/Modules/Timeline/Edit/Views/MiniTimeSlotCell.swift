import UIKit

class MiniTimeSlotCell: UITableViewCell
{
    static let cellIdentifier = "miniTimeSlotCell"
    
    @IBOutlet private(set) weak var categoryCircle: UIView!
    @IBOutlet private weak var lineView : LineView!
    @IBOutlet private weak var elapsedTime : UILabel!
    @IBOutlet private weak var categoryIcon: UIImageView!
    @IBOutlet private weak var activityTagView: ActivityTagView!
    @IBOutlet private weak var lineHeightConstraint: NSLayoutConstraint!
    
    func configure(with timeSlot: TimeSlot, alternativeEndTime: Date)
    {
        setupLine(with: timeSlot)
        setupElapsedTimeLabel(with: timeSlot, alternativeEndTime: alternativeEndTime)
        setupCategoryIcon(with: timeSlot)
        setupActivityTag(with: timeSlot)
    }
    
    private func setupLine(with timeSlot: TimeSlot)
    {
        lineHeightConstraint.constant = timeSlot.duration != nil ? calculatedLineHeight(for: timeSlot.duration!) : 16
        lineView.color = timeSlot.category.color
        lineView.collapsed = false
        lineView.fading = false
        lineView.layoutIfNeeded()
    }
    
    private func setupElapsedTimeLabel(with timeSlot: TimeSlot, alternativeEndTime: Date)
    {
        elapsedTime.textColor = timeSlot.category.color
        elapsedTime.text = timeSlot.duration != nil ? formatedElapsedTimeText(for: timeSlot.duration!) : formatedElapsedTimeText(for: alternativeEndTime.timeIntervalSince(timeSlot.startTime))
    }
    
    private func setupCategoryIcon(with timeSlot: TimeSlot)
    {
        categoryCircle.backgroundColor = timeSlot.category.color
        let image = UIImage(asset: timeSlot.category.icon)!
        let icon = categoryIcon!
        icon.image = image
        icon.contentMode = .scaleAspectFit
    }
    
    private func setupActivityTag(with timeSlot: TimeSlot)
    {
        guard let tagText = timeSlot.activity?.rawValue.capitalized else {
            activityTagView.isHidden = true
            return
        }
        
        activityTagView.isHidden = false
        activityTagView.configure(name: tagText)
    }
}
