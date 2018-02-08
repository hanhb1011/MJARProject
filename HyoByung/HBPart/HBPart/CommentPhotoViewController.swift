//
//  CommentPhotoViewController.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

class CommentPhotoViewController: UIViewController {
    
    static var comment : Comment = Comment()
    
    @IBOutlet weak var commentImageView: UIImageView!

    @IBAction func pickAnImage(_ sender: Any) {
        handleSelectedImage()
    }
    @IBAction func exitButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        //show the activity indicator
        SVProgressHUD.show()
        
        //comment data upload
        let ref: DatabaseReference! = Database.database().reference().child("comments").child(CommentTableViewController.restaurantId).childByAutoId()
        CommentPhotoViewController.comment.commentId = ref.key
        CommentPhotoViewController.comment.uid="temp"
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        CommentPhotoViewController.comment.date = formatter.string(from: Date())
        ref.setValue(CommentPhotoViewController.comment.toDictionary())
        
        //image upload
        if let image = UIImagePNGRepresentation(self.commentImageView.image!) {
            
            let storage = Storage.storage()
            let storageRef = storage.reference().child(ref.key+".png")
            storageRef.putData(image, metadata: nil){ metadata, error in
                SVProgressHUD.dismiss()
                self.navigationController?.dismiss(animated: true, completion: nil)
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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


extension CommentPhotoViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectedImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
//        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info["UIImagePickerControllerOriginalImage"] {
            let image = originalImage as! UIImage
            let resizedImage = image.crop(to: CGSize(width: 300.0, height: 300.0))
            self.commentImageView.image = resizedImage
            self.commentImageView.contentMode = .scaleToFill
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}


extension UIImage {

    
    func crop(to:CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = (contextImage.cgImage?.cropping(to: rect))!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, true, self.scale)
        draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized!
    }
}
