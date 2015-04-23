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
    let newUserCreationSuccess = "1000"
    let newUserCreationFailure = "1001"
    let getUserFailure = "1011"
    let updateCurrentSongSuccess = "1020"
    let updateCurrentSongFailure = "1021"
    let getNearbyUsersFailure = "1031"
    
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getNearbyUsers(userId: String, completion:(users: [User]) -> Void)
    {
        let radius = "1000000000000"
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": getNearbyUsersAction, "userId": userId, "radius": radius]
        
        Alamofire.request(.GET, userURL, parameters: params).responseJSON { (_, response, rawJSON, _) -> Void in
            var json = JSON(rawJSON!)
            println(response)
            println("GET NEARBY USER\n\(rawJSON)")
            
            var usersArr = [User]()
            if json.string != self.getNearbyUsersFailure {
                var jsonArr = json.array!
                
                for index in 0..<jsonArr.count {

                    let currentSong = NSURL(string: jsonArr[index]["currentSong"].stringValue)!
                    let id = jsonArr[index]["id"].stringValue
                    let lat = jsonArr[index]["lat"].stringValue
                    let lon = jsonArr[index]["lon"].stringValue
                    let profilePicURL = jsonArr[index]["profilePictureUrl"].stringValue
                    let lastSongCSV = jsonArr[index]["lastSongsCSV"].stringValue
                    
                    println(currentSong)
                    println(id)
                    println(lat)
                    println(lon)
                    println(profilePicURL)
                    println(lastSongCSV)

                    var nearbyUser = User(userID:id, profilePicture: profilePicURL, currentSongURL: currentSong, lattitude: lat, longitude: lon)
                    
                    usersArr.append(nearbyUser)
                }
            }
            completion(users: usersArr)
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func getUserInfo(userId: String, completion:(users: [User]) -> Void)
    {
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": getUserAction, "userId": userId]
        
        Alamofire.request(.GET, userURL, parameters: params).responseJSON { (_, response, rawJSON, _) -> Void in
            
            if rawJSON != nil
            {
                var json = JSON(rawJSON!)
                println("GET USER\n\(rawJSON)")
                let currentSong = json["currentSong"].stringValue
                let id = json["id"].stringValue
                let lat = json["lat"].stringValue
                let lon = json["lon"].stringValue
                let profilePicURL = json["profilePictureUrl"].stringValue
                let lastSongCSV = json["lastSongsCSV"].stringValue
            }
            
            completion(users: [])
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func updateCurrentSong(userId: String, song:String, completion:(users: [User]) -> Void)
    {
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": updateCurrentSongAction, "userId": userId, "newSong": song]
        
        Alamofire.request(.POST, userURL, parameters: params).responseJSON { (_, response, rawJSON, _) -> Void in
            var json = JSON(rawJSON!)
            
            completion(users: [])
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func createNewUser(spotifyId: String, name:String, lat:String, lon:String, profilePicture:String, completion:(users: [User]) -> Void)
    {
        var details:Dictionary<String,AnyObject>?
        details = ["error": "", "success": false]
        let params = ["action": newUserAction, "id": spotifyId, "name": name, "lat":"92", "lon":"94", "profilePictureUrl":profilePicture]
        
        Alamofire.request(.POST, userURL, parameters: params).responseString { (_, response, rawString, _) -> Void in
//            var json = JSON(rawJSON!)
            println("CREATE USER \(rawString)")
//            completion(users: [])
        }
    }
    
}