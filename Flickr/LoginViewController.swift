//
//  LoginViewController.swift
//  Flickr
//
//  Created by Labuser on 2/23/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(PFUser.currentUser() != nil){
            dispatch_async(dispatch_get_main_queue(), {()-> Void in
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TabViewController")
                self.presentViewController(vc, animated: true, completion: nil)
            })
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onSignIn(sender: AnyObject) {
        let username = usernameField.text ?? ""
        let password = usernameField.text ?? ""
        PFUser.logInWithUsernameInBackground(username, password: password) { (user:PFUser?, error:NSError?) -> Void in
            if user != nil{
                print("You are logged in")
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }else{
                self.alert( "Can't log in", message: "We weren't able to log you in")
            }
        }
    }
    @IBAction func onSignUp(sender: AnyObject) {
        
        let newUser = PFUser();
        if let username = usernameField.text where username != ""{
            newUser.username = usernameField.text
        }else{
            alert("Empty Field",message: "username can't be empty")
            return
        }
        if let password = passwordField.text where password != ""{
            newUser.password = passwordField.text
        }else{
            alert("Empty Field",message: "password can't be empty")
            return
        }
        
        
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("New User created");
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }else{
                print(error?.localizedDescription)
                self.alert("Can't sign up", message: "We weren't able to log you up" )
                

            }
        }
    }
    
    func alert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // handle case of user canceling. Doing nothing will dismiss the view.
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
