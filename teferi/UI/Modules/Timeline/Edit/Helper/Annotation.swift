import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation
{
    private let timeSlot : TimeSlot
    
    var image : UIImage
    {
        return imageOfPointWithCategory(color: timeSlot.category.color, categoryImage: timeSlot.category.icon.image)
    }
    
    var title: String?
    {
        return timeSlot.category.description
    }
    
    var subtitle: String?
    {
        return nil
    }
    
    var coordinate: CLLocationCoordinate2D
    {
        return timeSlot.location != nil ?
            CLLocationCoordinate2D(latitude: timeSlot.location!.latitude, longitude: timeSlot.location!.longitude) :
            CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    init(timeSlot: TimeSlot)
    {
        self.timeSlot = timeSlot
    }
    
    private func imageOfPointWithCategory(imageSize: CGSize = CGSize(width: 52, height: 52), color: UIColor, categoryImage: UIImage) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        drawPointWithCategory(frame: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height), color: color, categoryImage: categoryImage)
        
        let imageOfPointWithCategory = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return imageOfPointWithCategory
    }
    
    private func drawPointWithCategory(frame: CGRect, color: UIColor, categoryImage: UIImage)
    {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }
        
        
        //// Subframes
        let group: CGRect = CGRect(x: frame.minX + 2, y: frame.minY, width: frame.width - 4, height: frame.height)
        
        
        //// Group
        //// Oval Drawing
        let ovalPath = UIBezierPath()
        ovalPath.move(to: CGPoint(x: group.minX + 1.00000 * group.width, y: group.minY + 0.45833 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 0.61132 * group.width, y: group.minY + 0.90527 * group.height), controlPoint1: CGPoint(x: group.minX + 1.00000 * group.width, y: group.minY + 0.67639 * group.height), controlPoint2: CGPoint(x: group.minX + 0.83388 * group.width, y: group.minY + 0.85888 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 0.50000 * group.width, y: group.minY + 1.00000 * group.height), controlPoint1: CGPoint(x: group.minX + 0.58584 * group.width, y: group.minY + 0.91058 * group.height), controlPoint2: CGPoint(x: group.minX + 0.50000 * group.width, y: group.minY + 1.00000 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 0.38342 * group.width, y: group.minY + 0.90414 * group.height), controlPoint1: CGPoint(x: group.minX + 0.50000 * group.width, y: group.minY + 1.00000 * group.height), controlPoint2: CGPoint(x: group.minX + 0.40868 * group.width, y: group.minY + 0.90967 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 0.00000 * group.width, y: group.minY + 0.45833 * group.height), controlPoint1: CGPoint(x: group.minX + 0.16351 * group.width, y: group.minY + 0.85600 * group.height), controlPoint2: CGPoint(x: group.minX + 0.00000 * group.width, y: group.minY + 0.67467 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 0.50000 * group.width, y: group.minY + 0.00000 * group.height), controlPoint1: CGPoint(x: group.minX + 0.00000 * group.width, y: group.minY + 0.20520 * group.height), controlPoint2: CGPoint(x: group.minX + 0.22386 * group.width, y: group.minY + 0.00000 * group.height))
        ovalPath.addCurve(to: CGPoint(x: group.minX + 1.00000 * group.width, y: group.minY + 0.45833 * group.height), controlPoint1: CGPoint(x: group.minX + 0.77614 * group.width, y: group.minY + 0.00000 * group.height), controlPoint2: CGPoint(x: group.minX + 1.00000 * group.width, y: group.minY + 0.20520 * group.height))
        ovalPath.close()
        color.setFill()
        ovalPath.fill()
        
        
        //// Rectangle Drawing
        let rectangleRect = CGRect(x: group.minX + fastFloor(group.width * 0.20833 + 0.5), y: group.minY + fastFloor(group.height * 0.19231 + 0.5), width: fastFloor(group.width * 0.79167 + 0.5) - fastFloor(group.width * 0.20833 + 0.5), height: fastFloor(group.height * 0.73077 + 0.5) - fastFloor(group.height * 0.19231 + 0.5))
        let rectanglePath = UIBezierPath(rect: rectangleRect)
        context.saveGState()
        rectanglePath.addClip()
        context.translateBy(x: floor(rectangleRect.minX + 0.5 + ((rectangleRect.width - categoryImage.size.width) / 2)), y: floor(rectangleRect.minY + 0.5 + ((rectangleRect.height - categoryImage.size.height) / 2) ))
        context.scaleBy(x: 1, y: -1)
        context.translateBy(x: 0, y: -categoryImage.size.height)
        context.draw(categoryImage.cgImage!, in: CGRect(x: 0, y: 0, width: categoryImage.size.width, height: categoryImage.size.height))
        context.restoreGState()
    }
}
