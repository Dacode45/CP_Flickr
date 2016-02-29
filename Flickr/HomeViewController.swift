//
//  HomeViewController.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse
import Foundation

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var switchQueryButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var showOnlyMine = false
    var images : [PFObject]?{
        didSet{
            collectionView.reloadData()
        }
    }
    var selectedImage : PFObject?{
        didSet{
            print("Selected Image")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
        
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        collectionView.addSubview(loadingMoreView!)
        
        var insets = collectionView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        collectionView.contentInset = insets
        images = [PFObject]()
        // Do any additional setup after loading the view.
        getInitialImages()
    }
    func getInitialImages(){
        
        let query = PFQuery(className: "UserImage")
        query.orderByDescending("createdAt")
        if showOnlyMine{
            query.whereKey("author", equalTo: PFUser.currentUser()!)
        }
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock({ (images:[PFObject]?, error: NSError?) -> Void in
            if let images = images{
                self.images = images
            }else{
                print("Failed to load images")
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        PFUser.logOut()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login")
            self.presentViewController(viewController, animated: true, completion: nil)
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let images = images {
            return images.count
        }else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        //print("here")
        
        cell.image = images![indexPath.row]
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        let query = PFQuery(className: "UserImage")
        query.orderByDescending("createdAt")
        if showOnlyMine{
            query.whereKey("author", equalTo: PFUser.currentUser()!)
        }
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock({ (images:[PFObject]?, error: NSError?) -> Void in
            if let img = images{
                self.images? += img
                refreshControl.endRefreshing()
            }else{
                print("Failed to load images")
            }
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!isMoreDataLoading){
            let height = collectionView.contentSize.height
            let end = height - collectionView.bounds.size.height
            
            if(scrollView.contentOffset.y > end && collectionView.dragging){
                isMoreDataLoading = true
                let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView!.frame = frame
                loadingMoreView?.startAnimating()
                
                let query = PFQuery(className: "UserImage")
                query.orderByDescending("createdAt")
                if showOnlyMine{
                    query.whereKey("author", equalTo: PFUser.currentUser()!)
                }
                query.includeKey("author")
                query.limit = 20
                query.findObjectsInBackgroundWithBlock({ (images:[PFObject]?, error: NSError?) -> Void in
                    if let images = images{
                        self.images = images
                        self.loadingMoreView?.stopAnimating()
                    }else{
                        self.presentAlert("Exhausted", message: "No more images to load")
                        self.loadingMoreView?.stopAnimating()
                    }
                })
                
            }
        }
    }
    @IBAction func switchQuery(sender: AnyObject) {
        if showOnlyMine{
            showOnlyMine = false
            switchQueryButton.title = "Show All"
        }else{
            showOnlyMine = true
            switchQueryButton.title = "Show Mine"
        }
        
        images = []
        getInitialImages()
        collectionView.reloadData()
    }
    
    func presentAlert(title:String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedImage = images![indexPath.row]
        performSegueWithIdentifier("detailSegue", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("segueing: \(sender)")
        if let detailsView = segue.destinationViewController as? ImageDetailViewController{
            
            
            detailsView.tempImage = selectedImage
        }
    }
    

}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}