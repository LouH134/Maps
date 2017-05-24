//
//  ViewController.swift
//  Map
//
//  Created by Louis Harris on 5/8/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import WebKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tttLogo: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.bringSubview(toFront: tttLogo)
        
        searchBar.delegate = self
        
        
        
        turnToTechPin()
        restaurants()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectMapType(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            mapView.mapType = .standard
            break;
        case 1:
            mapView.mapType = .hybrid
            break;
        case 2:
            mapView.mapType = .satellite
            break;
        default:
            break;
        }
        
    }
    
    func turnToTechPin()
    {
        let annotation = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.708592, longitude: -74.014921))
        
        self.mapView.addAnnotation(annotation)
        annotation.title = "40 Rector Street"
        annotation.subtitle = "Turn To Tech"
        annotation.image = UIImage(named: "turnTechLogo")
        annotation.url = "http://turntotech.io/"
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        
        let region = MKCoordinateRegion(center: annotation.coordinate, span:span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func restaurants()
    {
        let clintonHall = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.708030, longitude: -74.014869))
        
        clintonHall.title = "90 Washington Street"
        clintonHall.subtitle = "Clinton Hall"
        clintonHall.image = UIImage(named: "ClintoHall")
        clintonHall.url = "http://clintonhallny.com/"
        self.mapView.addAnnotation(clintonHall)
        
        let bravo = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.708083, longitude: -74.013700))
        
        bravo.title = "94 Greenwhich Street"
        bravo.subtitle = "Cafe Bravo"
        bravo.image = UIImage(named: "Bravo")
        bravo.url = "https://www.google.com/search?q=Cafe+Bravo&oq=cafe&aqs=chrome.1.69i59l2j69i57j0l3.2043j0j4&sourceid=chrome&ie=UTF-8#q=Cafe+Bravo&rflfq=1&rlha=0&rllag=40707278,-74013008,107&tbm=lcl&rldimm=1992789177516966325&tbs=lrf:!2m4!1e17!4m2!17m1!1e2!2m1!1e2!2m1!1e1!2m1!1e3!3sEAE,lf:1,lf_ui:9"
        
        self.mapView.addAnnotation(bravo)
        
        let george = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.707879, longitude: -74.013542))
        
        george.title = "89 Greenwhich Street"
        george.subtitle = "George's Diner"
        george.image = UIImage(named: "banner")
        george.url = "http://georges-ny.com/"
        self.mapView.addAnnotation(george)
        
        let bk = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: 40.709637, longitude: -74.011912))
        
        bk.title = "106 Liberty Street"
        bk.subtitle = "Burger King"
        bk.image = UIImage(named: "BK")
        bk.url = "https://www.bk.com/"
        self.mapView.addAnnotation(bk)
        
        
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnView") as? MKPinAnnotationView
        
        if annView == nil {
            let ann = annotation as? LHAnnotation
            annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnView")
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = ann?.image
            annView?.leftCalloutAccessoryView = imageView
            //create a button that goes to web view on the right callout accessory view
            annView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annView?.canShowCallout = true
        }

        return annView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //works with hardcoded annotations but not generated
        let ann = view.annotation as? LHAnnotation
        self.performSegue(withIdentifier: "showWeb", sender: ann)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeb"{
            let annotation = sender as! LHAnnotation
            let navVC = segue.destination as! UINavigationController
            let webVC = navVC.topViewController as! WebVC
            webVC.url = annotation.url
            
        }
    }
    
    func mapView(_mapView: MKMapView, didUpdate userLocation:MKUserLocation)
    {
        print(userLocation.coordinate)
        let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 250, 250)
        self.mapView.setRegion(region, animated: true)
    }
}

extension ViewController : UISearchBarDelegate {
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //perfrom MKLocalSearch based on searchBar.text
       let req = MKLocalSearchRequest()
        req.naturalLanguageQuery = self.searchBar.text
        req.region = self.mapView.region
        
        let search = MKLocalSearch(request: req)
        search.start(completionHandler: {(result, error) in
            guard let result = result else{
                print("There was an error searching for: \(req.naturalLanguageQuery ?? "") error: \(error?.localizedDescription ?? "")")
                return
            }
        
        for item in result.mapItems {
            
            let annotation = LHAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
            annotation.title = item.placemark.title
            annotation.subtitle = item.url?.absoluteString
            annotation.url = item.url?.absoluteString
            self.mapView.addAnnotation(annotation)
        }
        
        })
    }
    
    
    
}






