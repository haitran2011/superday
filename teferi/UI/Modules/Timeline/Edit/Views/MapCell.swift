import UIKit
import MapKit

class MapCell: UITableViewCell
{
    static let cellIdentifier = "mapCell"
    
    @IBOutlet private weak var mapView: MKMapView!
    fileprivate let annotationViewIdentifier = "point"
    private var dataSource : [Annotation]!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        mapView.layer.cornerRadius = 10
        mapView.delegate = self
    }
    
    func configure(with timeSlots: [TimeSlot])
    {
        mapView.removeAnnotations(mapView.annotations)
        self.dataSource = timeSlots.map(toAnnotation)
        centreMap()
        mapView.addAnnotations(dataSource)
        mapView.showsUserLocation = true
    }
    
    private func centreMap()
    {
        let centre = dataSource.centerCoordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                    longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: centre, span: span)
        mapView.setRegion(region, animated: false)
        mapView.regionThatFits(region)
    }
    
    private func toAnnotation(_ timeSlot: TimeSlot) -> Annotation
    {
        return Annotation(timeSlot: timeSlot)
    }
}

extension MapCell : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation
        {
            return nil
        }
        
        var annotationView : MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
        
        if annotationView == nil
        {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
        }
        
        annotationView?.annotation = annotation
        let point = annotation as! Annotation
        annotationView?.image = point.image
        annotationView?.centerOffset = CGPoint(x: 0, y: -52 / 2)
        annotationView?.canShowCallout = true
        
        return annotationView
    }
}
