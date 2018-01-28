//
//  CommentTableViewController.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentTableViewController: UITableViewController {
    var comments : [Comment] = []
    var averageRating : Double = 0.0
    @IBOutlet weak var averageRatingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromServer()
        
        
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
        var comment = comments[indexPath.row]
        
        cell.titleLabel.text = comment.title!
        cell.ratingLabel.text = String(comment.rating!)
        cell.dateLabel.text = comment.date!
        cell.commentLabel.text = comment.comment!
        
        return cell
    }
    
    func getDataFromServer(){
        
        var ref: DatabaseReference!
        ref = Database.database().reference().child("comments")
        
        //receive data from server
        ref.observe(.value) { snapshot in
            let root : NSDictionary = snapshot.value as! NSDictionary
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
            if self.comments.count > 0 {
                self.averageRating /= Double(self.comments.count)
                self.averageRatingLabel.text = "Average : \(round(self.averageRating*100)/100)"
                self.tableView.reloadData()
            }
        }
        
        
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}