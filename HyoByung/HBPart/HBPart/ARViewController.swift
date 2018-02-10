//
//  ARViewController.swift
//  HBPart
//
//  Created by 한효병 on 29/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation
import MapKit

class ARViewController: UIViewController {
    
    var sceneLocationView = SceneLocationView()
    
    let locationManager = LocationManager()
    
    func refreshFavoritesTable() {
        
    }
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        print("arviewcontroller self : \(self)")
        
        // Do any additional setup after loading the view.
        
        //print("위치 \(sceneLocationView.currentLocation()?.coordinate.latitude)")
        if let currentLocation = sceneLocationView.currentLocation() {
            //print("kim sung soo")
            let lat = currentLocation.coordinate.latitude
            let lng = currentLocation.coordinate.longitude
            let altitude = currentLocation.altitude
            
            let places = getPlaceInfos(lat: lat, lng: lng)
            if places.count > 0 {
                for place in places {
                    let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
                    let location = CLLocation(coordinate: coordinate, altitude: altitude)
                    let image = UIImage(named: "pin")!
                    let annotationNode = LocationAnnotationNode(location: location, image: image, r_id: place.place_id)
                    
                    sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                    //sceneLocationView.update
                }
                sceneLocationView.run()
                view.addSubview(sceneLocationView)
            }
        }
    }
    
    static func updateNodes(){
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        if(touch.view == self.sceneLocationView){
            print("touch working")
            let viewTouchLocation:CGPoint = touch.location(in: sceneLocationView)
            guard let result = sceneLocationView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }
            
            showNextController(r_id : result.node.name!)
        }
    }
    
    func showNextController(r_id: String) {
        let uvc = self.storyboard!.instantiateViewController(withIdentifier: "CommentTableViewController") // 1
        uvc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve // 2
        CommentTableViewController.restaurantId = r_id
        self.present(uvc, animated: true) // 3
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "restaurantInfoFromAR" {
            if textField.text!.count > 0 {
                let destination = segue.destination as! CommentTableViewController
                CommentTableViewController.restaurantId = textField.text
            }
        }
    }
    
    func getPlaceInfos(lat: Double, lng: Double) -> [PlaceInfo] {
        var placeInfos :[PlaceInfo] = []
        var fullUrl :String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lng)&language=ko&radius=500&type=restaurant&key=AIzaSyCzY5m4aopjsOKjpDJOEFMLdY9Tl0ZlF2Y"
        
        let url = URL(string: fullUrl)
        var datalist = NSDictionary()
        
        do {
            datalist = try JSONSerialization.jsonObject(with:Data(contentsOf : url!), options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        }  catch {
            print("Error loading Data")
        }
        
        if let restaurants = datalist["results"] as? NSArray {
            for res in restaurants {
                if let restaurant = res as? NSDictionary {
                    var lat1 : Double = 0.0
                    var lng1 : Double = 0.0
                    var place_id1 : String = ""
                    
                    if let geometry = restaurant["geometry"] as? NSDictionary {
                        if let location = geometry["location"] as? NSDictionary {
                            if let lat = location["lat"] as? Double {
                                lat1 = lat
                            }
                            
                            if let lng = location["lng"] as? Double {
                                lng1 = lng
                            }
                            
                        }
                    }
                    
                    if let place_id = restaurant["place_id"] as? String {
                        place_id1 = place_id
                    }
                    placeInfos += [PlaceInfo(lat1, lng1, place_id1)]
                }
            }
        }
        
        
        return placeInfos
    }
    
    func updateNode(location: CLLocation) {
        
        let lat = location.coordinate.latitude //currentLocation.coordinate.latitude
        let lng = location.coordinate.longitude //currentLocation.coordinate.longitude
        let altitude = location.altitude
        
        let places = getPlaceInfos(lat: lat, lng: lng)
        if places.count > 0 {
            for place in places {
                let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
                let location = CLLocation(coordinate: coordinate, altitude: altitude)
                let image = UIImage(named: "image")!
                let annotationNode = LocationAnnotationNode(location: location, image: image, r_id: place.place_id)
                
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
            sceneLocationView.run()
            view.addSubview(sceneLocationView)
        }
    }
    
}




//MARK: LocationManager
@available(iOS 11.0, *)
extension ARViewController: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        print("locationManagerDidUpdateLocation in arviewcontroller")
    }
    
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationAccuracy) {
        
    }
    
    func locationaManagerDidUpdateCurrentLocation(_ locationManager: LocationManager, location: CLLocation) {
        print("god hyo byung")
        updateNode(location: location)
    }
    
    
}

