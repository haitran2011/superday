import UIKit

class SimpleDetailCell: UITableViewCell
{
    static let cellIdentifier = "simpleDetailCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    func show(title: String, value: String?)
    {
        titleLabel.text = title
        valueLabel.text = value
    }
}
