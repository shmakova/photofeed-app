//
//  Feed.swift
//  PhotoFeed
//
//  Created by Mike Spears on 2016-01-08.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import Foundation



func fixJsonData (data: NSData) -> NSData {
    var dataString = String(data: data, encoding: NSUTF8StringEncoding)!
    dataString = dataString.stringByReplacingOccurrencesOfString("\\'", withString: "'")
    return dataString.dataUsingEncoding(NSUTF8StringEncoding)!
    
}


class Feed: NSObject, NSCoding {
    
    let items: [FeedItem]
    let sourceURL: NSURL
    
    init (items newItems: [FeedItem], sourceURL newURL: NSURL) {
        self.items = newItems
        self.sourceURL = newURL
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.items, forKey: "feedItems")
        aCoder.encodeObject(self.sourceURL, forKey: "feedSourceURL")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let storedItems = aDecoder.decodeObjectForKey("feedItems") as? [FeedItem]
        let storedURL = aDecoder.decodeObjectForKey("feedSourceURL") as? NSURL
        
        guard storedItems != nil && storedURL != nil  else {
            return nil
        }
        self.init(items: storedItems!, sourceURL: storedURL! )
        
    }
    
    convenience init? (data: NSData, sourceURL url: NSURL) {
        
        var newItems = [FeedItem]()
        
        let fixedData = fixJsonData(data)
        
        var jsonObject: Dictionary<String, AnyObject>?
        
        do {
            jsonObject = try NSJSONSerialization.JSONObjectWithData(fixedData, options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String,AnyObject>
        } catch {
            
        }
        
        guard let feedRoot = jsonObject else {
            return nil
        }
        
        guard let items = feedRoot["items"] as? Array<AnyObject>  else {
            return nil
        }
        
        
        for item in items {
            
            guard let itemDict = item as? Dictionary<String,AnyObject> else {
                continue
            }
            guard let media = itemDict["media"] as? Dictionary<String, AnyObject> else {
                continue
            }
            
            guard let urlString = media["m"] as? String else {
                continue
            }
            
            guard let url = NSURL(string: urlString) else {
                continue
            }
            
            let title = itemDict["title"] as? String
            
            newItems.append(FeedItem(title: title ?? "(no title)", imageURL: url))
            
        }
        
        self.init(items: newItems, sourceURL: url)
    }
    
}