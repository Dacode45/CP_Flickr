//
//  ImageDetailViewController.swift
//  Flickr
//
//  Created by Labuser on 2/26/16.
//  Copyright © 2016 TeamKickAss. All rights reserved.
//

import UIKit
import Parse

class ImageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var upvoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var pointsCounter: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentView: UIView!

    @IBOutlet weak var tableView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let estimatedHeight: CGFloat = 300
    
    var image: PFObject?{
        didSet{
            let imageFile = image?.objectForKey("media") as! PFFile
            imageFile.getDataInBackgroundWithBlock { (data:NSData?, error:NSError?) -> Void in
                if(error == nil){
                    self.imageView.image = UIImage(data:data!)
                    self.imageView.layer.cornerRadius = 30
                    self.imageView.layer.masksToBounds = true
                    self.imageView.layer.borderColor = UIColor.whiteColor().CGColor
                    self.imageView.layer.borderWidth = 1
                }
            }
            UserComment.getCommentsOfImage(image!) { (c:[PFObject]?, err:NSError?) -> Void in
                if err == nil{
                    self.comments = c
                }
            }
            pointsCounter.text = "\(image?.objectForKey("likesCount")) Points"
        }
    }
    var comments: [PFObject]?{
        didSet{
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
      
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.estimatedRowHeight = estimatedHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: commentView.frame.origin.y + commentView.frame.size.height)
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendComment(sender: AnyObject) {
        let comment = commentField.text
        if comment?.characters.count > 0{
            UserComment.postUserComment(comment!, image: image!, withCompletion: { (success:Bool, err:NSError?) -> Void in
                if (success){
                    let image = self.image
                    self.image = image
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        cell.comment = comments![indexPath.row]
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = comments{
            return comments.count
        }else{
            return 0;
        }
    }
    @IBAction func upvote(sender: AnyObject) {
        image?.incrementKey("likesCount")
        let oldUpTint = upvoteButton.imageView?.tintColor
        let oldDownTint = downVoteButton.imageView?.tintColor
        upvoteButton.imageView?.tintColor = UIColor.blackColor()
        downVoteButton.imageView?.tintColor = UIColor.blackColor()
        
        image?.saveInBackgroundWithBlock({ (success:Bool, err:NSError?) -> Void in
            if err == nil{
                do {
                 try self.image?.fetch()
                    let image = self.image
                    self.image = image
                    self.upvoteButton.imageView?.tintColor = UIColor.greenColor()
                }catch {
                    print("Can't update")
                    self.upvoteButton.imageView?.tintColor = oldUpTint
                    self.downVoteButton.imageView?.tintColor = oldDownTint
                }
            }
        })
    }
    
    @IBAction func downvote(sender: AnyObject) {
        image?.incrementKey("likesCount")
        let oldUpTint = upvoteButton.imageView?.tintColor
        let oldDownTint = downVoteButton.imageView?.tintColor
        upvoteButton.imageView?.tintColor = UIColor.blackColor()
        downVoteButton.imageView?.tintColor = UIColor.blackColor()
        
        image?.saveInBackgroundWithBlock({ (success:Bool, err:NSError?) -> Void in
            if err == nil{
                do {
                    try self.image?.fetch()
                    let image = self.image
                    self.image = image
                    self.downVoteButton.imageView?.tintColor = UIColor.redColor()
                }catch {
                    print("Can't update")
                    self.upvoteButton.imageView?.tintColor = oldUpTint
                    self.downVoteButton.imageView?.tintColor = oldDownTint
                }
            }
        })
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
