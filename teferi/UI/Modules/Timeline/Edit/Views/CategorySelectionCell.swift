import UIKit

class CategorySelectionCell: UITableViewCell
{
    static let cellIdentifier = "categorySelectionCell"
    
    private(set) var editView : EditTimeSlotView!
    private var timelineItem : TimelineItem!

    func configure(with categoryProvider: CategoryProvider, timelineItem: TimelineItem)
    {
        self.timelineItem = timelineItem
        
        guard let _ = editView
        else
        {
            editView = EditTimeSlotView(categoryProvider: categoryProvider)
            editView.backgroundColor = .clear
            contentView.addSubview(editView)
            editView.constrainEdges(to: contentView)
            return
        }
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        editView.onEditBegan(point: CGPoint(x: 0, y: 34), timelineItem: timelineItem)
        editView.backgroundColor = .clear
    }
}
