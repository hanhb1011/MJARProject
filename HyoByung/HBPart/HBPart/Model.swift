//
//  Model.swift
//  Test
//
//  Created by Gihyouk Lee on 29/01/2018.
//  Copyright © 2018 Gihyouk Lee. All rights reserved.
//

import Foundation


class DetailPlace{
    var name:String?
    var vicinity:String?
    var open_now:Bool?
    var weekday_text:[String]?
    var formatted_phone_number:String?
    var formatted_address:String?
    var photos:[Photo]?
    
    init(){
        name = nil
        vicinity = nil
        open_now = nil
        weekday_text = nil
        formatted_address = nil
        formatted_phone_number = nil
        photos = nil
    }
    
}

class PlaceInfo {
    var lat :String
    var lng :String
    var place_id :String
    
    init(_ lat:String, _ lng:String, _ place_id:String) {
        self.lat = lat
        self.lng = lng
        self.place_id = place_id
    }
}

class Photo {
    var height :String
    var width :String
    var photo_reference :String
    
    init(_ height:String,_ width:String,_ photo_reference:String) {
        self.height = height
        self.width = width
        self.photo_reference = photo_reference
    }
}

