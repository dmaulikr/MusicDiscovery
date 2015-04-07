//
//  ViewController.swift
//  SpotifyTest
//
//  Created by Nick Martinson on 4/1/15.
//  Copyright (c) 2015 Nick Martinson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SPTAuthViewDelegate
{
    var session:SPTSession!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    /**********************************************************************************************************
    *   Checks to see if there is a valid Spotify session saved in the defaults. If so, it checks if it is still
    *   valid. If not, it refreshes the stored session
    *********************************************************************************************************/
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(true)
        if let sessionObj:AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("SpotifySession")
        {
            // convert the stored session object back to SPTSession
            let sessionData = sessionObj as NSData
            let session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionData) as SPTSession
            
            // check if the retrieved session is still valid
            if !session.isValid()
            {
                // Renew the session
                SPTAuth.defaultInstance().renewSession(session, callback: { (error, session) -> Void in
                    if error != nil { println("Renew session error") }
                    else
                    {
                        // store the refreshed session in user defaults
                        let sessionDataNew = NSKeyedArchiver.archivedDataWithRootObject(session)
                        NSUserDefaults.standardUserDefaults().setObject(sessionDataNew, forKey: "SpotifySession")
                        self.session = session
                    }
                })
            }
            performSegueWithIdentifier("LoggedInSegue", sender: self)
        }
        
    }

    /**********************************************************************************************************
    *   This creates the Spotify modal login view
    *********************************************************************************************************/
    @IBAction func loginPressed(sender: AnyObject)
    {
        // create the Spotify login modal view
        let authView = SPTAuthViewController.authenticationViewController()
        authView.delegate = self
        authView.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        authView.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.definesPresentationContext = true
        presentViewController(authView, animated: true, completion: nil)
        self.modalPresentationStyle = .CurrentContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /**********************************************************************************************************
    *   SPOTIFY DELEGATE METHODS
    *********************************************************************************************************/
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!)
    {
        println("Log in failed")
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!)
    {
        
//        self.session = session
        // request the current users information
        SPTRequest.userInformationForUserInSession(session, callback: { (error, user) -> Void in
            let name = user.displayName
            let image = (user as SPTUser).largestImage
            println("image \(image.imageURL)")
            println(name)
        })
            
        let defaults = NSUserDefaults.standardUserDefaults()
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session!)
        defaults.setObject(sessionData, forKey: "SpotifySession")
        performSegueWithIdentifier("LoggedInSegue", sender: self)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!)
    {
        println("Log In Canceled")
    }
    
    
}

