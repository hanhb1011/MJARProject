//
//  Model.swift
//  TableViewTest
//
//  Created by mme on 2018. 1. 25..
//  Copyright © 2018년 mme. All rights reserved.
//

import Foundation

class Comment {
    
    let date :NSDate?
    let comment :String?
    let title :String?
    let rating :Float?
    let commentId :String?
    let password:String?
    let uid :String? //작성자 식별

    init(date:NSDate, comment:String, title:String, rating:Float, commentId:String, password:String, uid:String){
        self.date = date
        self.comment = comment
        self.title = title
        self.rating = rating
        self.commentId = commentId
        self.password = password
        self.uid = uid
    }
    
    init(comment:String, title:String, rating:Float){
        self.date = NSDate()
        self.comment = comment
        self.title = title
        self.rating = rating
        self.commentId = nil
        self.password = nil
        self.uid = nil
    }
    
    
}
