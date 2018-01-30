//
//  FavoritesTableViewController.swift
//  HBPart
//
//  Created by 한효병 on 29/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController, FavoritesDelegate {
    
    var favoritesData : [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getFavoritesData()
        
    }
    
    func refreshFavoritesTable() {
        getFavoritesData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoritesData.count
    }

    func getFavoritesData() {
        self.favoritesData = []
        let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"restaurantData.dat"
        
        if let dataReceived = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) {
            let dict = dataReceived as! [String:[String:String]]
            favoritesData = Array(dict)
            self.tableView.reloadData()
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoritesTableViewCell
        let data = favoritesData[indexPath.row] as? (String, NSDictionary)
        cell.testLabel.text = "id : \(data!.0)"
        
        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "restaurantInfoFromFavorites" {
            if let index = self.tableView.indexPathForSelectedRow?.row {
                if let destination = segue.destination as? CommentTableViewController, let data = favoritesData[index] as? (String, NSDictionary){
                    destination.favoritesDelegate = self
                    CommentTableViewController.restaurantId = data.0
                }
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

    
    // MARK: - Navigation

 

}
