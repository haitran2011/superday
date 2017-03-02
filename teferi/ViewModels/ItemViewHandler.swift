import UIKit

class ItemViewHandler<ViewType, ItemType> where ViewType: UIButton
{
    typealias Attribute = (image: UIImage, color: UIColor)
    
    private(set) var visibleCells = [ViewType]()
    private var reusableCells = Set<ViewType>()
    
    private(set) var items : [ItemType]
    private let attributeSelector : (ItemType) -> Attribute
    
    init(items: [ItemType], attributeSelector: @escaping ((ItemType) -> (UIImage, UIColor)))
    {
        guard !items.isEmpty else { fatalError("empty data array") }
        
        self.items = items
        self.attributeSelector = attributeSelector
    }
    
    private func itemIndex(before index: Int?, forward: Bool) -> Int
    {
        guard let index = index else { return 0 }
        
        guard items.count != 1 else { return 0 }
        
        let beforeIndex = index + (forward ? 1 : -1)
        
        return (beforeIndex + items.count) % items.count
    }
    
    func lastVisibleCell(forward: Bool) -> ViewType?
    {
        guard !visibleCells.isEmpty else { return nil }
        
        return forward ? visibleCells.last! : visibleCells.first!
    }
    
    func cell(before cell: ViewType?, forward: Bool, cellSize: CGSize) -> ViewType
    {
        let nextItemIndex = itemIndex(before: cell?.tag, forward: forward)
        
        let attributes = attributeSelector(items[nextItemIndex])
        
        var cellToReturn = reusableCells.isEmpty ?
            ViewType(frame: CGRect(origin: .zero, size: cellSize)) :
            reusableCells.removeFirst()
        
        cellToReturn = cellWithAttributes( cell: cellToReturn, attributes: attributes)
        cellToReturn.layer.cornerRadius = min(cellSize.width, cellSize.height) / 2
        cellToReturn.adjustsImageWhenHighlighted = false
        cellToReturn.tag = nextItemIndex
        visibleCells.insert(cellToReturn, at: forward ? visibleCells.endIndex : visibleCells.startIndex)
        
        return cellToReturn
    }
    
    func remove(cell: ViewType)
    {
        let index = visibleCells.index(of: cell)
        visibleCells.remove(at: index!)
        cell.removeFromSuperview()
        reusableCells.insert(cell)
    }
    
    func cleanAll()
    {
        visibleCells.forEach { (cell) in
            cell.removeFromSuperview()
        }
        
        visibleCells.removeAll()
        
        reusableCells.forEach { (cell) in
            cell.removeFromSuperview()
        }
        
        reusableCells.removeAll()
    }
    
    private func cellWithAttributes(cell: ViewType, attributes: Attribute) -> ViewType
    {
        cell.backgroundColor = attributes.color
        cell.setImage(attributes.image, for: .normal)
        return cell
    }
}