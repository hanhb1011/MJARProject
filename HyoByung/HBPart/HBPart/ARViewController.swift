//
//  ARViewController.swift
//  HBPart
//
//  Created by 한효병 on 29/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit

class ARViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
 

}
