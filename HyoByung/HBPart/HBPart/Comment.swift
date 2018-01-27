//
//  Comment.swift
//  HBPart
//
//  Created by 한효병 on 27/01/2018.
//  Copyright © 2018 한효병. All rights reserved.
//

import Foundation

class Comment {
    
    var comment : String?
    var commentId : String?
    var date : String?
    var password : String?
    var rating : Double?
    var title : String?
    var uid : String?
    
    init(){
        
        self.comment = nil
        self.commentId = nil
        self.date = nil
        self.password = nil
        self.rating = nil
        self.title = nil
        self.uid = nil
        
    }
    
    init(comment:String, commentId : String, date : String, password : String, rating : Double, title : String, uid : String) {
        
        self.comment = comment
        self.commentId = commentId
        self.date = date
        self.password = password
        self.rating = rating
        self.title = title
        self.uid = uid
        
    }
    
    func toDictionary () -> NSDictionary {
        return ["comment":self.comment!,
                "commentId":self.commentId!,
            "date":self.date!,
            "password":self.password!,
            "rating":self.rating!,
            "title":self.title!,
            "uid":self.uid!
        ]
    }
    
}
