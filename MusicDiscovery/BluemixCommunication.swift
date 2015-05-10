//
//  BluemixCommunication.swift
//  MusicDiscovery
//
//  Created by Nick Martinson on 4/21/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import Foundation
import Alamofire

/******************************************************************************************
*
******************************************************************************************/
extension Alamofire.Request
{
    class func imageResponseSerializer() -> Serializer{
        return { request, response, data in
            if( data == nil) {
                return (nil,nil)
            }
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self{
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}

class BluemixCommunication
{
    let userURL = "http://musicdiscovery.mybluemix.net/User"
    let newUserAction = "100"
    let getUserAction = "101"
    let updateCurrentSongAction = "102"
    let getNearbyUsersAction = "103"
    let updateLocationAction = "106"
    
    let newUserCreationSuccess = "1000"
    let newUserCreationFailure = "1001"
    let getUserFailure = "1011"
    let updateCurrentSongSuccess = "1020"
    let updateCurrentSongFailure = "1021"
    let getNearbyUsersFailure = "1031"
    let updateLocationSuccess = "1060"
    let updateLocationFailure = "1061"
    
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func updateLocation(userId: String, lat:String, lon:String)
    {
        var details:Dictionary<String,AnyObject>?
        var params:[String:String]
        if lat == "" && lon == ""
        {
            params = ["action": updateLocationAction, "userId":userId]
        }
        else
        {
            params = ["action": updateLocationAction, "userId":userId, "lat":lat, "lon":lon]
        }
        println("UPDATE LOCATION \(params)")
        Alamofire.request(.POST, userURL, parameters: params).responseString { (_, response, string, _) -> Void in
            if string! == self.updateLocationFailure
            {
                println("Update location failure")
            }
            else
            {
                println("Update location success")
            }
        }
    }

    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getNearbyUsers(userId: String, completion:(users: [User]) -> Void)
    {
        let radius = UserPreferences().getRadius()
        println("SEARCH RADIUS \(radius)")
        let params:[String : AnyObject] = ["action": getNearbyUsersAction, "userId": userId, "radius": radius]
        
        Alamofire.request(.GET, userURL, parameters: params).responseJSON { (_, response, rawJSON, _) -> Void in
            println("NEARBY USERS\n\(rawJSON)")
            if rawJSON != nil
            {
                var users:[User] = []
                var json = JSON(rawJSON!)
                for(var i = 0; i < json.count; i++)
                {
                    let currentSong = json[i]["currentSong"].stringValue
                    let id = json[i]["id"].stringValue
                    let lat = json[i]["lat"].stringValue
                    let lon = json[i]["lon"].stringValue
                    let profilePicURL = json[i]["profilePictureUrl"].stringValue
                    let lastSongCSV = json[i]["lastSongsCSV"].stringValue
                    
                    let coords = CLLocation(latitude: (lat as NSString).doubleValue, longitude: (lon as NSString).doubleValue)
                    let user = User(realName: "", userID: id, profilePicture: profilePicURL, currentSongURL: NSURL(string: currentSong)!, location: coords)
                    users.append(user)
                }
                completion(users: users)
            }
            else
            {
                completion(users: [])
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getUserInfo(userId: String, completion:(user: User?) -> Void)
    {
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": getUserAction, "userId": userId]
        
        Alamofire.request(.GET, userURL, parameters: params).responseJSON { (_, response, rawJSON, _) -> Void in
            println("USER INFO\n\(rawJSON)")
            var json = JSON(rawJSON!)
            if json.stringValue != self.getUserFailure //rawJSON!.string != self.getUserFailure
            {
                var json = JSON(rawJSON!)
                let currentSong = json["currentSong"].stringValue
                let id = json["id"].stringValue
                let lat = json["lat"].stringValue
                let lon = json["lon"].stringValue
                let profilePicURL = json["profilePictureUrl"].stringValue
                let lastSongCSV = json["lastSongsCSV"].stringValue
                let user = User(realName: "", userID: id, profilePicture: profilePicURL, currentSongURL: NSURL(string: currentSong)!)
                completion(user: user)
            }
            else
            {
                completion(user: nil)
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func updateCurrentSong(userId: String, track:String, album:String, artist:String, URI:String)
    {
        let params = ["action": updateCurrentSongAction, "userId": userId, "track": track, "album":album, "artist":artist, "uri":URI]

        Alamofire.request(.POST, userURL, parameters: params).responseString { (_, response, string, _) -> Void in
//            println("UPDATE SONG \(string)")
            if string! == "1020"
            {
                println("update song success")
            }
            else if string! == "1021"
            {
                println("Update song failure")
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createNewUser(spotifyId: String, name:String, lat:String, lon:String, profilePicture:String, completion:() -> Void)
    {
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": newUserAction, "id": spotifyId, "name": name, "lat":lat, "lon":lon, "profilePictureUrl":profilePicture]
        
        Alamofire.request(.POST, userURL, parameters: params).responseString { (_, response, rawString, _) -> Void in
            println("CREATE USER \(rawString)")
            completion()
        }
    }
    
}