//
//  ImagePickerViewController.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ImagePickerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image : PFObject?
    
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if image == nil{
            presentImagePicker()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    func presentImagePicker(){
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
            let edited = info[UIImagePickerControllerEditedImage] as! UIImage
            self.newImageView.image = edited
            
    }
    
    func imagePicker(){
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        
        
        let returnIcon = UIBarButtonItem()
        returnIcon.tintColor = UIColor.redColor()
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func uploadImage(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        UserImage.postUserImage(newImageView.image, withCaption: commentField.text) { (success: Bool, error: NSError?) -> Void in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            print(error)
        }
    }

    @IBAction func getNewImage(sender: AnyObject) {
        presentImagePicker()
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
