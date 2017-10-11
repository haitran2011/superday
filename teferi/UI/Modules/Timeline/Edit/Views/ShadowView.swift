import UIKit

class ShadowView: UIView
{
    override func draw(_ rect: CGRect)
    {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Color Declarations
        let color = UIColor(red: 0.871, green: 0.871, blue: 0.871, alpha: 1.000)
        
        //// Shadow Declarations
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.35)
        shadow.shadowOffset = CGSize(width: 0, height: -0.5)
        shadow.shadowBlurRadius = 5
        
        //// curvedLine Drawing
        let curvedLinePath = UIBezierPath()
        curvedLinePath.move(to: CGPoint(x: rect.maxX - 6.61, y: rect.minY + 9.65))
        curvedLinePath.addLine(to: CGPoint(x: rect.maxX - 6.22, y: rect.minY + 9.75))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 0.66, y: rect.minY + 15.31), controlPoint1: CGPoint(x: rect.maxX - 3.64, y: rect.minY + 10.69), controlPoint2: CGPoint(x: rect.maxX - 1.6, y: rect.minY + 12.73))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 0, y: rect.minY + 19), controlPoint1: CGPoint(x: rect.maxX - 0.28, y: rect.minY + 16.49), controlPoint2: CGPoint(x: rect.maxX - 0.1, y: rect.minY + 17.62))
        curvedLinePath.addLine(to: CGPoint(x: rect.maxX - 1.09, y: rect.minY + 19))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 1.66, y: rect.minY + 16.31), controlPoint1: CGPoint(x: rect.maxX - 1.2, y: rect.minY + 18.05), controlPoint2: CGPoint(x: rect.maxX - 1.38, y: rect.minY + 17.19))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 7.22, y: rect.minY + 10.75), controlPoint1: CGPoint(x: rect.maxX - 2.6, y: rect.minY + 13.73), controlPoint2: CGPoint(x: rect.maxX - 4.64, y: rect.minY + 11.69))
        curvedLinePath.addLine(to: CGPoint(x: rect.maxX - 7.61, y: rect.minY + 10.65))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 16.2, y: rect.minY + 10), controlPoint1: CGPoint(x: rect.maxX - 9.59, y: rect.minY + 10), controlPoint2: CGPoint(x: rect.maxX - 11.79, y: rect.minY + 10))
        curvedLinePath.addLine(to: CGPoint(x: rect.minX + 16.29, y: rect.minY + 10))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 7.32, y: rect.minY + 10.75), controlPoint1: CGPoint(x: rect.minX + 11.89, y: rect.minY + 10), controlPoint2: CGPoint(x: rect.minX + 9.69, y: rect.minY + 10))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 1.75, y: rect.minY + 16.31), controlPoint1: CGPoint(x: rect.minX + 4.73, y: rect.minY + 11.69), controlPoint2: CGPoint(x: rect.minX + 2.69, y: rect.minY + 13.73))
        curvedLinePath.addLine(to: CGPoint(x: rect.minX + 1.66, y: rect.minY + 16.7))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 1.17, y: rect.minY + 19), controlPoint1: CGPoint(x: rect.minX + 1.42, y: rect.minY + 17.41), controlPoint2: CGPoint(x: rect.minX + 1.27, y: rect.minY + 18.15))
        curvedLinePath.addLine(to: CGPoint(x: rect.minX + 0.09, y: rect.minY + 19))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 0.66, y: rect.minY + 15.7), controlPoint1: CGPoint(x: rect.minX + 0.17, y: rect.minY + 17.69), controlPoint2: CGPoint(x: rect.minX + 0.33, y: rect.minY + 16.67))
        curvedLinePath.addLine(to: CGPoint(x: rect.minX + 0.75, y: rect.minY + 15.31))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 6.32, y: rect.minY + 9.75), controlPoint1: CGPoint(x: rect.minX + 1.69, y: rect.minY + 12.73), controlPoint2: CGPoint(x: rect.minX + 3.73, y: rect.minY + 10.69))
        curvedLinePath.addCurve(to: CGPoint(x: rect.minX + 15.29, y: rect.minY + 9), controlPoint1: CGPoint(x: rect.minX + 8.69, y: rect.minY + 9), controlPoint2: CGPoint(x: rect.minX + 10.89, y: rect.minY + 9))
        curvedLinePath.addLine(to: CGPoint(x: rect.maxX - 15.2, y: rect.minY + 9))
        curvedLinePath.addCurve(to: CGPoint(x: rect.maxX - 6.61, y: rect.minY + 9.65), controlPoint1: CGPoint(x: rect.maxX - 10.79, y: rect.minY + 9), controlPoint2: CGPoint(x: rect.maxX - 8.59, y: rect.minY + 9))
        curvedLinePath.close()
        context.saveGState()
        context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
        color.setFill()
        curvedLinePath.fill()
        context.restoreGState()
    }
}
