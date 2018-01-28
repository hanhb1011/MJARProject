//
//  CommentPhotoViewController.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CommentPhotoViewController: UIViewController {
    
    static var comment : Comment = Comment()
    
    @IBOutlet weak var testLabel: UILabel!
    @IBAction func submitClicked(_ sender: Any) {
        var ref: DatabaseReference! = Database.database().reference().child("comments").childByAutoId()
        CommentPhotoViewController.comment.commentId = ref.key
        CommentPhotoViewController.comment.uid="temp"
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommentPhotoViewController.comment.date = formatter.string(from: Date())
        ref.setValue(CommentPhotoViewController.comment.toDictionary())
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testLabel.text = "rating : \(CommentPhotoViewController.comment.rating)\ntitle : \(CommentPhotoViewController.comment.title)\ncomment : \(CommentPhotoViewController.comment.comment)\npassword :\(CommentPhotoViewController.comment.password)"
        
        // Do any additional setup after loading the view.
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