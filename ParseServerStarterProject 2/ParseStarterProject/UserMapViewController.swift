//
//  UserMapViewController.swift
//  Tinsnappok
//
//  Created by Tasio on 26/4/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import MapKit

class UserMapViewController: UIViewController {

    var user: User?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let regionRadius : CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.user?.location)!, regionRadius, regionRadius)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = self.user?.name
        //annotation.subtitle = "\(String(describing: self.user?.location))"
        annotation.coordinate = (self.user?.location)!
        self.mapView.showAnnotations([annotation], animated: true)
        self.mapView.selectAnnotation(annotation,animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserMapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil
        }
        var annotationView : MKPinAnnotationView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        imageView.image = self.user?.image
        annotationView?.leftCalloutAccessoryView = imageView
        
        return annotationView
    }

}
