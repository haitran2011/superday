
import UIKit

class MultiSlotHeaderCell: UITableViewCell
{
    static let cellIdentifier = "multiSlotHeaderCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    
    func configure(timelineItem: TimelineItem)
    {
        titleLabel.text = timelineItem.category.description
        valueLabel.text = timelineItem.slotStartAndStopTimeText
    }
}
