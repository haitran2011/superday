import UIKit

class CategorySelectionCell: UITableViewCell
{
    static let cellIdentifier = "categorySelectionCell"
    
    private(set) var editView : EditTimeSlotView!
    private var timelineItem : TimelineItem!

    func configure(with categoryProvider: CategoryProvider, timelineItem: TimelineItem)
    {
        self.timelineItem = timelineItem
        
        if editView == nil
        {
            editView = EditTimeSlotView(categoryProvider: categoryProvider)
            editView.backgroundColor = .clear
            contentView.addSubview(editView)
            editView.constrainEdges(to: contentView)
        }
        
        editView.onEditBegan(point: CGPoint(x: 0, y: 34), timelineItem: timelineItem, hideCurrentCategory: false)
        editView.backgroundColor = .clear
    }
}
