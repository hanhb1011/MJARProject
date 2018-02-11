//
//  CommentTableViewController.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD
import PINRemoteImage
import SceneKit

class CommentTableViewController: UITableViewController {
    var comments : [Comment] = []
    var restaurantInfos : [(Int,String)] = []
    var url : String?
    var averageRating : Double = 0.0
    var isFavorite : Bool = false
    static var restaurantId : String! = "default"
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"/restaurantData.dat"
    
    @IBOutlet var restaurantImageView: UIImageView!
    @IBOutlet var restaurantTitleLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var numOfCommentsLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CommentTableViewController.restaurantId == "default" {
            dismiss(animated: true, completion: nil)
        }
        
        SVProgressHUD.show()
        
        var detailPlace : DetailPlace!
        detailPlace = getDetailPlace(CommentTableViewController.restaurantId)
        
        
        if let str = detailPlace.name {
            restaurantTitleLabel.text = str
        }
        if let str = detailPlace.formatted_address {
            restaurantInfos.append((0, str))
        }
        if let str = detailPlace.formatted_phone_number {
            restaurantInfos.append((1, str))
        }
        if let str = detailPlace.weekday_text {
            let today = Date()
            var format = DateFormatter()
            format.dateFormat = "e"
            let index = (Int(format.string(from: today))! + 4) % 7
            restaurantInfos.append((2, str[index]))
        }
        if let photos = detailPlace.photos {
            let urls = getPhotoUrl(photos: photos)
            if urls.count > 0 {
                self.url = urls[0]
                restaurantImageView.pin_setImage(from: URL(string: urls[0]))
            }
        }
        tableView.reloadData()
        
        getDataFromServer()
        
        if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
            var dict = dataReceived as! [String:[String:String]]
            if dict[CommentTableViewController.restaurantId] != nil {
                self.isFavorite = true
                self.favoriteButton.setImage(UIImage(named : "icons8-heart-outline-50-3"), for: .normal)
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func exitButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        print(filePath)
        guard let button = sender as? UIButton else {
            return
        }
        if restaurantInfos.count == 0 {
            return
        }
        
        if self.isFavorite {
            button.setImage(UIImage(named: "icons8-heart-outline-50-2"), for: .normal)
            
            //delete
            if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
                var dict = dataReceived as! [String:[String:String]]
                dict[CommentTableViewController.restaurantId] = nil
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
                print(dataReceived)
            }
            
            self.isFavorite = false
        } else {
            button.setImage(UIImage(named : "icons8-heart-outline-50-3"), for: .normal)
            
            var infoDict :[String:String] = [:]
            if let url = self.url {
                infoDict["photoUrl"] = url
            }
            if let name = self.restaurantTitleLabel.text {
                infoDict["name"] = name
            }
            
            for (key, value) in restaurantInfos {
                if key==0 { //addr
                    infoDict["address"] = value
                } else if key==1 { //phone
                    infoDict["phone"] = value
                }
            }
            
            if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
                var dict = dataReceived as! [String:[String:String]] //temp
                dict[CommentTableViewController.restaurantId] = infoDict
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
                
            } else {
                var dict = [String:[String:String]]() //temp
                dict[CommentTableViewController.restaurantId] = infoDict
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
            }
            print(infoDict)
            self.isFavorite = true
        }
        
        
    }
    
    
  
    func getDetailPlace(_ place_id : String) -> DetailPlace {
        let place = DetailPlace()
        let fullUrl :String = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + place_id + "&language=ko&key="+ARViewController.key
        let url = URL(string: fullUrl)
        var datalist = NSDictionary()
        
        do {
            datalist = try JSONSerialization.jsonObject(with:Data(contentsOf : url!), options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        }  catch {
            print("Error loading Data")
        }
        if let result = datalist["result"] as? NSDictionary {
            if let name = result["name"] as? String {
                place.name = name
            }
            
            if let formatted_address = result["formatted_address"] as? String {
                place.formatted_address = formatted_address
            }
            
            if let formatted_phone_number = result["formatted_phone_number"] as? String {
                place.formatted_phone_number = formatted_phone_number
            }
            
            if let opening_hours = result["opening_hours"] as? NSDictionary {
                if let open_now = opening_hours["open_now"] as? Bool {
                    place.open_now = open_now
                }
                
                if let weekday_text = opening_hours["weekday_text"] as? [String] {
                    place.weekday_text = weekday_text
                }
            }
            
            if let vicinity = result["vicinity"] as? String {
                place.vicinity = vicinity
            }
            
            if let photos = result["photos"] as? NSArray {
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
                            place.photos?.append(Photo(height, width, photo_reference))
                        }
                    }
                }
            }
            
        }
        
        return place
    }
    
    func getPhotoUrl(photos:[Photo]) -> [String] {
        var urls :[String] = []
        for photo in photos {
            var url :String = ""
            if Int(photo.width)! > 1000 && Int(photo.height)! > 1000 {
                url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1000&photoreference=" + photo.photo_reference + "&key="+ARViewController.key
            }else {
                url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=" + photo.width + "&maxheight=" + photo.height +  "&photoreference=" + photo.photo_reference + "&key=AIzaSyB-jtfEKziLML6XohRb_DndnA0mlZoXaZ0"
            }
            //let url :String = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=" + photo.width + "&maxheight=" + photo.height +  "&photoreference=" + photo.photo_reference + "&key=AIzaSyCzY5m4aopjsOKjpDJOEFMLdY9Tl0ZlF2Y"
            urls.append(url)
        }
        
        return urls
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return restaurantInfos.count
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
           
            return 50
            
        } else {
            return 100
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as!CommentTableViewCell
            let comment = comments[indexPath.row]
            
            cell.ratingLabel.text = String(comment.rating!)
            cell.dateLabel.text = comment.date!
            cell.commentLabel.text = comment.comment!
            
            let storage = Storage.storage()
            let storageRef = storage.reference().child(comment.commentId!+".png")
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // default image
                } else {
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        cell.commentImageView?.image = image
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as!RestaurantTableViewCell
            
            let info :(Int, String) = restaurantInfos[indexPath.row]
            
            if info.0 == 0 {
                cell.iconImageView.image = UIImage(named : "if_icon-ios7-location-outline_211766.png")
            } else if info.0 == 1 {
                cell.iconImageView.image = UIImage(named : "if_icon-ios7-telephone-outline_211829.png")
            } else {
                cell.iconImageView.image = UIImage(named : "if_icon-ios7-clock-outline_211606.png")
            }
            
            cell.infoLabel.text = info.1
            cell.infoLabel.sizeToFit()
            return cell
        }
    }
    
    func getDataFromServer(){
        
        
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child("comments").child(CommentTableViewController.restaurantId)
        
        //receive data from server
        ref.observe(.value) { snapshot in
            self.comments = []
            SVProgressHUD.dismiss()
            
            guard let root : NSDictionary = snapshot.value as? NSDictionary else {
                return
            }
            let dataset = root.allValues
            for data in dataset {
                let dict = data as! NSDictionary
                let comment = Comment()
                guard let rating = dict["rating"] as? Int else {
                    return
                }
                comment.commentId = "\(dict["commentId"]!)"
                comment.rating = Double(rating)
                comment.comment = "\(dict["comment"]!)"
                comment.date = "\(dict["date"]!)"
                comment.title = "\(dict["title"]!)"
                comment.uid = "\(dict["uid"]!)"
                comment.password="\(dict["password"]!)"
                
                self.averageRating += comment.rating!
                self.comments.append(comment)
            }
            
            //and update ui
            
            DispatchQueue.main.async {
                if self.comments.count > 0 {
                    self.tableView.reloadData()
                    self.averageRating /= Double(self.comments.count)
                    self.averageRatingLabel.text = "\(round(self.averageRating*10)/10)"
                    self.numOfCommentsLabel.text = "\(self.comments.count)"
                }
            }
            
        }
        
    }
    
    
}
