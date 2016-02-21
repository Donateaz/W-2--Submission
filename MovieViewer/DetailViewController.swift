//
//  DetailViewController.swift
//  MovieViewer
//
//  Created by Donatea Zefi on 2/14/16.
//  Copyright © 2016 Donatea Zefi. All rights reserved.
//

import UIKit
import AVKit
import MBProgressHUD

class DetailViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var networkErrorView: UIImageView!
    @IBOutlet weak var videoView: UIWebView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBAction func trailerButton(sender: AnyObject) {
        view.addSubview(videoView)
        videoView.hidden = false
    videoView.loadRequest(NSURLRequest(URL: videoUrl!))
    }
    
    
    var movie: NSDictionary!
    var movieId: String!
    var refreshControl: UIRefreshControl!
    var videoUrl: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     videoView.hidden = true
        
       scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        scrollView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        UIView.animateWithDuration(3, delay: 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            let pair = self.scrollView.center
            self.scrollView.contentOffset = CGPoint(x: 0, y: pair.y + 100)
            }, completion: nil)
     
        let title = movie["title"] as? String
        titleLabel.text = title
    
        let overview = movie["overview"]
        overviewLabel.text = overview as? String
        overviewLabel.sizeToFit()
        ratingLabel.text = String(format: " %.2f /10", movie["vote_average"] as! Float)
        
        movieId = movie["id"]!.stringValue

        //programatic instantiation refresh Controller
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        scrollView.insertSubview(refreshControl, atIndex: 0);

        let releaseDate = movie["release_date"] as! String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString(releaseDate)
        dateFormatter.dateFormat = "MM.dd.yy"
        let dateText = dateFormatter.stringFromDate(date!)
        releaseDateLabel.text = dateText
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            
            let posterURL = NSURL(string: baseURL + posterPath)
            posterImageView.setImageWithURL(posterURL!)
          
        }
    }
    func reloadData() { // repopulate elements in Details view
        if let movie = movie {
            titleLabel.text = movie["title"] as? String;
            
            taglineLabel.text = movie["tagline"] as? String;
            
            var genres = [""];
            genres.removeAll();
            for genre in (movie["genres"] as? [NSDictionary])! {
                genres.append(genre["name"] as! String);
            }
            genresLabel.text = genres.joinWithSeparator(", ");
            
            var runtime = movie["runtime"]!.integerValue!;
            if(runtime == 0) {
                runtimeLabel.text = "Runtime Varies";
            } else {
                let minutes = runtime % 60;
                runtime /= 60;
                let hours = runtime % 24;
                runtimeLabel.text = "\(hours) hr \(minutes) min";
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func movieRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(movieId)?api_key=\(apiKey)")
        print(url)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            let durationText = responseDictionary["runtime"]!.stringValue
                            self.runtimeLabel.text = durationText + " mins"
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.refreshControl.endRefreshing()
                            //self.networkErrorView.hidden = true
                    }
                } else {
                    
                    //self.tableView.hidden = true
                    self.networkErrorView.hidden = false
                    self.view.bringSubviewToFront(self.networkErrorView)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.refreshControl.endRefreshing()
                    UIView.animateWithDuration(1.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.networkErrorView.alpha = 1.0
                        }, completion: {
                            (finished: Bool) -> Void in
                            UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                self.networkErrorView.alpha = 0.0
                                }, completion: nil)
                    })
                    
                    print("There was a network error")
                }
        });
        task.resume()
        
    }
    
    func videoRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey)")
        print(url)
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            let vidData = responseDictionary["results"] as! [NSDictionary]
                            let vd : NSDictionary = vidData[0] as NSDictionary
                            let site = vd["site"] as! String
                            let key = vd["key"] as! String
                            if site == "YouTube" {
                                self.videoUrl = NSURL(string: "https://www.youtube.com/watch?v=\(key)")
                            } else {
                                print(site)
                                print(key)
                            }
                            self.refreshControl.endRefreshing()
                    }
                } else {
                    
                    self.networkErrorView.hidden = false
                    self.view.bringSubviewToFront(self.networkErrorView)
                    UIView.animateWithDuration(1.5, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.networkErrorView.alpha = 1.0
                        }, completion: {
                            (finished: Bool) -> Void in
                            UIView.animateWithDuration(1.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                                self.networkErrorView.alpha = 0.0
                                }, completion: nil)
                    })
                    
                    print("There was a network error")
                }
        });
        task.resume()
        
    }
    func didRefresh() {
        movieRequest()
        videoRequest()
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