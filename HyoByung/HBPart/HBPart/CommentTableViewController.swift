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


class CommentTableViewController: UITableViewController {
    var comments : [Comment] = []
    var averageRating : Double = 0.0
    var isFavorite : Bool = false
    static var restaurantId : String! = "default"
    let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"restaurantData.dat"
    
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var numOfCommentsLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func exitButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        
        guard let button = sender as? UIButton else {
            return
        }
        if self.isFavorite {
            button.setImage(UIImage(named: "whitestar32"), for: .normal)
            
            if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
                var dict = dataReceived as! [String:[String:String]] //temp
                dict[CommentTableViewController.restaurantId] = nil
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
                
            }
            
            
            self.isFavorite = false
        } else {
            button.setImage(UIImage(named : "icons8-star-32.png"), for: .normal)
            
            if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
                var dict = dataReceived as! [String:[String:String]] //temp
                dict[CommentTableViewController.restaurantId] = ["key":"val"]
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
                
            } else {
                var dict = [String:[String:String]]() //temp
                dict[CommentTableViewController.restaurantId] = ["key":"val"]
                NSKeyedArchiver.archiveRootObject(dict, toFile: filePath)
            }
            
            
            self.isFavorite = true
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getDataFromServer()
        
        if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
            var dict = dataReceived as! [String:[String:String]]
            if dict[CommentTableViewController.restaurantId] != nil {
                self.isFavorite = true
                self.favoriteButton.setImage(UIImage(named : "icons8-star-32.png"), for: .normal)
            }
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as!CommentTableViewCell
        let comment = comments[indexPath.row]
        
        cell.titleLabel.text = comment.title!
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
        
    }
    
    func getDataFromServer(){
        
        SVProgressHUD.show()
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child("comments").child(CommentTableViewController.restaurantId)
        
        //receive data from server
        ref.observe(.value) { snapshot in
            
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
