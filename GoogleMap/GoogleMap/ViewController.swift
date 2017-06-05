//
//  ViewController.swift
//  GoogleMap
//
//  Created by Louis Harris on 5/24/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    let apiKey = "AIzaSyCx0eUcMWzGolzcmgjInwzJlQ3amgus6pU"
    var name:String!
    var snippet:String!
    var placeID:String!
    var photoReference:String!
    var websiteString:String!
    var latitude:Double!
    var longitude:Double!
    var newMarkers = [MyMarker]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(40.708592, -74.014921), zoom: 12.5, bearing: 0, viewingAngle: 0)
        
        self.mapView.isMyLocationEnabled = true
        self.mapView.camera = camera
        self.mapView.delegate = self
        
        searchBar.delegate = self
        
        hardCodedPins()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hardCodedPins()
    {
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2DMake(40.708592, -74.014921)
        marker1.title = "Turn To Tech"
        marker1.snippet = "40 Rector Street"
        marker1.map = self.mapView
        marker1.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2DMake(40.708030, -74.014869)
        marker2.title = "Clinton Hall"
        marker2.snippet = "90 Washington Street"
        marker2.map = self.mapView
        marker2.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
        
        
        let marker3 = GMSMarker()
        marker3.position = CLLocationCoordinate2DMake(40.708083, -74.013700)
        marker3.title = "Cafe Bravo"
        marker3.snippet = "94 Greenwhich Street"
        marker3.map = self.mapView
        marker3.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
    }

    @IBAction func changeMapType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.mapView.mapType = GMSMapViewType.normal
            break;
        case 1:
            self.mapView.mapType = GMSMapViewType.hybrid
            break;
        case 2:
            self.mapView.mapType = GMSMapViewType.satellite
            break;
        default:
            break;
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let infoWindow = Bundle.main.loadNibNamed("CustomMarker", owner: nil, options: nil)?[0] as? CustomMarker else {return nil}
        
        
        infoWindow.title.text = marker.title
        infoWindow.detail.text = marker.snippet
       
//        if the marker is cast as MyMarker set the MyMarker pic and the infowindow's pic is the MyMarker pic otherwise the infowindow's pic is the ttt pic
        if let marker = marker as? MyMarker,
              let picToSet = marker.pic {
        infoWindow.imageLogo.image = picToSet
        } else {
             infoWindow.imageLogo.image = UIImage(named: "tttLogo")
        }

        
        return infoWindow
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let currentCoord = mapView.camera.target
        let currentLat = currentCoord.latitude
        let currentLong = currentCoord.longitude
        
        self.newMarkers.removeAll()
        self.mapView.clear()
        
        guard let keyWord = self.searchBar.text else {return}
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(currentLat),\(currentLong)&radius=500&keyword=\(keyWord)&key=\(apiKey)"
        
        let url:URL = URL(string: urlString)!
        
        //get data
        URLSession.shared.dataTask(with:url){(data, response, error) in
            guard let myData = data
                else {return}
            
            //turn data to dictionary
            guard let json = try? JSONSerialization.jsonObject(with: myData, options:[]) as! [String: AnyObject]
                else {return}
            
            print(json)
            
            let results = json["results"]! as! [[String:AnyObject]]
            
            //when in results dictionary get the geometry dictionary and then location key is a string for anyobject
            for result in results{
                guard let locationDic = result["geometry"]?["location"] as? [String:AnyObject]
                    else{continue}
                
                guard let long = locationDic["lng"] as? Double
                    else{continue}
                self.longitude = long
                print(long)
                
                
                guard let lat = locationDic["lat"] as? Double
                    else{continue}
                self.latitude = lat
                print(lat)
                
                
                guard let name = result["name"]
                    else{continue}
                let searchName = String(describing: name)
                self.name = searchName
                print(searchName)
                
                guard let photoDic = result["photos"] as? [[String:AnyObject]]
                    else{continue}
                
                guard let photoRef = photoDic[0]["photo_reference"] as? String
                    else{continue}
                self.photoReference = photoRef

                
                guard let vicinity = result["vicinity"]
                    else{continue}
                let vSnippet = String(describing: vicinity)
                self.snippet = vSnippet
                print(vSnippet)
                
                guard let placeID = result["place_id"]
                    else{continue}
                let id = String(describing: placeID)
                self.placeID = id
                
                
                
                DispatchQueue.main.async {
                    
                    let newMarker = self.createMarker()
                    self.newMarkers.append(newMarker)
                }
                
            }
            
        }.resume()
        
    }
    
    func downloadImageFor(marker: MyMarker){
        
        
        let urlPhotoString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference!)&key=\(apiKey)"
        
        guard let photoURL = URL(string: urlPhotoString)
            else{return}
        
        URLSession.shared.dataTask(with: photoURL){ (data, _, _) in
            guard let imageData = data
                else{return}
            
            guard let image = UIImage(data: imageData)
                else{return}
            
            DispatchQueue.main.async {
                marker.pic = image
            }
            }.resume()

        
    }
 
    func createMarker() -> MyMarker
    {
        let searchMarker = MyMarker()
        
        searchMarker.position = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        searchMarker.title = self.name
        searchMarker.snippet = self.snippet
        searchMarker.map = self.mapView
        searchMarker.placeID = self.placeID
        searchMarker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
        downloadImageFor(marker: searchMarker)
        getWebSiteFor(marker: searchMarker)
       
        return searchMarker
    }
    
    func getWebSiteFor(marker: MyMarker)
    {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID!)&key=\(apiKey)"
        //print(urlString)
        
        guard let webSiteURL = URL(string: urlString)
            else{return}
        
        URLSession.shared.dataTask(with: webSiteURL){(data, response, error) in
            guard let myData = data
                else {return}
            
            guard let json = try? JSONSerialization.jsonObject(with: myData, options:[]) as! [String: AnyObject]
                else {return}
            
            guard let result = json["result"] as? [String:AnyObject] else{
                return
            }
            
           // for result in results{
            guard  let website = result["website"] as? String else{
                return
            }
            print(website)
//            if(website == nil){
//                website = "something"
//            }
                  //  else{continue}
                //let webString = String(describing: website)
            
                DispatchQueue.main.async {
                    marker.website = website
                }
                
           // }
        }.resume()
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let infoWindowMarker = marker as? MyMarker
        self.performSegue(withIdentifier: "showWeb", sender: infoWindowMarker)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeb"{
            let marker = sender as! MyMarker
            let navVC = segue.destination as! UINavigationController
            let webVC = navVC.topViewController as! WebVC
            webVC.url = marker.website
        }
    }
    
}
