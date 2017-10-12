import Foundation
import MapKit

extension Array
{
    func firstOfType<T>() -> T
    {
        return flatMap { $0 as? T }.first!
    }
    
    func lastOfType<T>() -> T
    {
        return flatMap { $0 as? T }.last!
    }
    
    func groupBy<Key: Hashable>(_ selectKey: (Element) -> Key) -> [[Element]]
    {
        var groups = [Key:[Element]]()
        
        for element in self
        {
            let key = selectKey(element)
            
            if case nil = groups[key]?.append(element)
            {
                groups[key] = [element]
            }
        }
        
        return groups.map { $0.value }
    }
    
    func safeGetElement(at index: Int) -> Element?
    {
        let element : Element? = indices.contains(index) ? self[index] : nil
        return element
    }
    
    func splitBy(_ sameGroup: (Element, Element) -> Bool) -> [[Element]]
    {
        var groups = [[Element]]()
        
        for element in self
        {
            guard let lastGroup = groups.last,
                let lastElement = lastGroup.last else {
                    groups = [[element]]
                    continue
            }
            if sameGroup(lastElement, element) {
                groups = groups.dropLast() + [lastGroup + [element]]
                continue
            } else {
                groups = groups + [[element]]
                continue
            }
        }
        
        return groups
    }
    
    func splitBy<Key: Equatable>(_ selectKey: (Element) -> Key) -> [[Element]]
    {
        var groups = [[Element]]()
        
        for element in self
        {
            guard let lastGroup = groups.last,
                let lastElement = lastGroup.last else {
                    groups = [[element]]
                    continue
            }
            if selectKey(lastElement) == selectKey(element) {
                groups = groups.dropLast() + [lastGroup + [element]]
                continue
            } else {
                groups = groups + [[element]]
                continue
            }
        }
        
        return groups
    }
}

extension Array where Element : Hashable
{
    func distinct() -> [Element]
    {
        return Array(Set(self))
    }
    
    public func toDictionary<Value: Any>(_ generateElement: (Element) -> Value?) -> [Element: Value]
    {
        var dict = [Element:Value]()
        for key in self
        {
            guard let element = generateElement(key) else { continue }
            dict.updateValue(element, forKey: key)
        }
        return dict
    }
}

extension Array where Element == Annotation
{
    var centerCoordinate : CLLocationCoordinate2D
    {
        guard
            let maxLatitude = maxLatitude,
            let minLatitude = minLatitude,
            let maxLongitude = maxLongitude,
            let minLongitude = minLongitude
            else { return CLLocationCoordinate2D(latitude: 40.6401, longitude: 22.9444) }
        
        return CLLocationCoordinate2D(latitude: (maxLatitude + minLatitude) / 2, longitude: (maxLongitude + minLongitude) / 2)
    }
    
    var maxLatitude : Double?
    {
        let point = self.sorted(by: { (element1, element2) -> Bool in
            return element1.coordinate.latitude > element2.coordinate.latitude
        }).first
        
        return point?.coordinate.latitude
    }
    
    var minLatitude : Double?
    {
        let point = self.sorted(by: { (element1, element2) -> Bool in
            return element1.coordinate.latitude < element2.coordinate.latitude
        }).first
        
        return point?.coordinate.latitude
    }
    
    var maxLongitude : Double?
    {
        let point = self.sorted(by: { (element1, element2) -> Bool in
            return element1.coordinate.longitude > element2.coordinate.longitude
        }).first
        
        return point?.coordinate.longitude
    }
    
    var minLongitude : Double?
    {
        let point = self.sorted(by: { (element1, element2) -> Bool in
            return element1.coordinate.longitude < element2.coordinate.longitude
        }).first
        
        return point?.coordinate.longitude
    }
}
