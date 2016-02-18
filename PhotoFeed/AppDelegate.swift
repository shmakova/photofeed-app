//
//  AppDelegate.swift
//  PhotoFeed
//
//  Created by Mike Spears on 2016-01-07.
//  Copyright © 2016 YourOganisation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSUserDefaults.standardUserDefaults().registerDefaults(["PhotoFeedURLString": "https://api.flickr.com/services/feeds/photos_public.gne?tags=kitten&format=json&nojsoncallback=1"])

        return true
    }


    func applicationDidBecomeActive(application: UIApplication) {
        let urlString = NSUserDefaults.standardUserDefaults().stringForKey("PhotoFeedURLString")
        print(urlString)
        
        guard let foundURLString = urlString else {
            return
        }
        
        if let url = NSURL(string: foundURLString) {
            self.updateFeed(url, completion: { (feed) -> Void in
                let viewController = application.windows[0].rootViewController as? ImageFeedTableViewController
                viewController?.feed = feed
            })
        }
    }

    
    func updateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                let feed = Feed(data: data!, sourceURL: url)
                
                if let goodFeed = feed {
                    if self.saveFeed(goodFeed) {
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastUpdate")
                    }
                }
                
                print("loaded Remote feed!")
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completion(feed: feed)
                })
            }
            
        }
        
        task.resume()
    }
    
    func feedFilePath() -> String {
        let paths = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let filePath = paths[0].URLByAppendingPathComponent("feedFile.plist")
        return filePath.path!
    }
    
    func saveFeed(feed: Feed) -> Bool {
        let success = NSKeyedArchiver.archiveRootObject(feed, toFile: feedFilePath())
        assert(success, "failed to write archive")
        return success
    }
    
    func readFeed(completion: (feed: Feed?) -> Void) {
        let path = feedFilePath()
        let unarchivedObject = NSKeyedUnarchiver.unarchiveObjectWithFile(path)
        completion(feed: unarchivedObject as? Feed)
    }
    
    
    func loadOrUpdateFeed(url: NSURL, completion: (feed: Feed?) -> Void) {
        
        let lastUpdatedSetting = NSUserDefaults.standardUserDefaults().objectForKey("lastUpdate") as? NSDate
        
        var shouldUpdate = true
        if let lastUpdated = lastUpdatedSetting where NSDate().timeIntervalSinceDate(lastUpdated) < 20 {
            shouldUpdate = false
        }
        if shouldUpdate {
            self.updateFeed(url, completion: completion)
        } else {
            self.readFeed { (feed) -> Void in
                if let foundSavedFeed = feed where foundSavedFeed.sourceURL.absoluteString == url.absoluteString {
                    print("loaded saved feed!")
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        completion(feed: foundSavedFeed)
                    })
                } else {
                    self.updateFeed(url, completion: completion)
                }
            }
        }
    }

}

