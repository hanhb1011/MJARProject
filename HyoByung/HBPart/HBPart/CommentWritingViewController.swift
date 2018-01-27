//
//  CommentWritingViewController.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit

class CommentWritingViewController: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView!.layer.borderWidth = 1
        commentTextView!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        titleTextField!.layer.borderWidth = 1
        titleTextField!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        passwordTextField!.layer.borderWidth = 1
        passwordTextField!.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        commentTextView.text = "Comment"
        commentTextView.textColor = UIColor.lightGray
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
        
        CommentPhotoViewController.comment.comment = commentTextView.text
        CommentPhotoViewController.comment.title = titleTextField.text
        CommentPhotoViewController.comment.password = passwordTextField.text
        
    }
 

}
