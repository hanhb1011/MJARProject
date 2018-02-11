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
import PINRemoteImage

class ARViewController: UIViewController {
    
    static let key :String = "AIzaSyChdWCTPRAQbk3y9Vx03R6hY2JABlbnoVQ"
    
    var sceneLocationView = SceneLocationView()
    
    let locationManager = LocationManager()
    
    func refreshFavoritesTable() {
        
    }
    
    var locationAnnotationNodes :[LocationAnnotationNode] = []
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        // Do any additional setup after loading the view.
        
        if let currentLocation = sceneLocationView.currentLocation() {
            updateNode(location: currentLocation)
            view.addSubview(sceneLocationView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first as! UITouch
        if(touch.view == self.sceneLocationView){
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
        var fullUrl :String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lng)&language=ko&radius=100&type=restaurant&key="+ARViewController.key
        
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
                    
                    var photos1 :[Photo] = []
                    if let photos = restaurant["photos"] as? NSArray {
                        for ph in photos {
                            if let photo = ph as? NSDictionary {
                                var height1 :String? = nil
                                if let height = photo["height"] as? Int {
                                    height1 = String(height)
                                }
                                var width1 :String? = nil
                                if let width = photo["width"] as? Int {
                                    width1 = String(width)
                                }
                                var photo_reference1 :String? = nil
                                if let photo_reference = photo["photo_reference"] as? String {
                                    photo_reference1 = photo_reference
                                }
                                
                                if let height = height1, let width = width1, let photo_reference = photo_reference1 {
                                    photos1.append(Photo(height, width, photo_reference))
                                }
                            }
                        }
                    }
                    placeInfos += [PlaceInfo(lat1, lng1, place_id1, photos1)]
                }
            }
        }
        
        
        return placeInfos
    }
    
    
    func getPhotoUrl2(photos:[Photo]) -> [String] {
        var urls :[String] = []
        for photo in photos {
            let url: String
            
            if Int(photo.width)! > 500 && Int(photo.height)! > 500 {
                url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=" + photo.photo_reference + "&key="+ARViewController.key
            } else {
                url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=" + photo.width + "&maxheight=" + photo.height +  "&photoreference=" + photo.photo_reference + "&key="+ARViewController.key
            }

            urls.append(url)
        }
        
        return urls
    }
    
    func updateNode(location: CLLocation) {
        
        for locationNode in locationAnnotationNodes {
            sceneLocationView.removeLocationNode(locationNode: locationNode)
        }
        locationAnnotationNodes.removeAll()
        
        
        let lat = location.coordinate.latitude //currentLocation.coordinate.latitude
        let lng = location.coordinate.longitude //currentLocation.coordinate.longitude
        let altitude = location.altitude
        
        let places = getPlaceInfos(lat: lat, lng: lng)
        if places.count > 0 {
            for place in places {
                let coordinate = CLLocationCoordinate2D(latitude: place.lat, longitude: place.lng)
                let location = CLLocation(coordinate: coordinate, altitude: altitude)
                //////////
                var image : UIImage?
                image = UIImage(named: "pin")!
//                if place.photos.count > 0 {
//
//                    print("ininininininininininininininin")
//                    let urls = getPhotoUrl2(photos: place.photos)
//                    let imageView = UIImageView()
//                    imageView.image = UIImage(named: "pin")
//
//                    if urls.count > 0 {
//                        print("in2in2in2in2in2in2in2in2in2in2in2in2")
//                        imageView.pin_setImage(from: URL(string: urls[0]))
//                        image = imageView.image
//                        image?.crop(to: CGSize(width: 100.0, height: 100.0))
//                    }
//                } else {
//                    image = UIImage(named: "pin")!
//                }
                
                let annotationNode = LocationAnnotationNode(location: location, image: image!, r_id: place.place_id)
                locationAnnotationNodes.append(annotationNode)
                sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
            }
        }
        
        sceneLocationView.run()
    }
    
}




//MARK: LocationManager
@available(iOS 11.0, *)
extension ARViewController: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {

    }
    
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationAccuracy) {
        
    }
    
    func locationaManagerDidUpdateCurrentLocation(_ locationManager: LocationManager, location: CLLocation) {
//        sceneLocationView.scene.rootNode.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode() }
        
        updateNode(location: location)
    }
    
    
}

