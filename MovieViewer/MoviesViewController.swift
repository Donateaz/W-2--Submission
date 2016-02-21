//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Donatea Zefi on 2/14/16.
//  Copyright © 2016 Donatea Zefi. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorView: UIImageView!
    
    var movies: [NSDictionary]?
    var filterMovies : [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var endpoint: String!

    //search bar display
    var searchController = UISearchController(searchResultsController: nil)

    
   //search bar
    @IBAction func resultsButton(sender: AnyObject) {
       
        self.presentViewController(searchController, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //error
        view.addSubview(networkErrorView)
        
        //search bar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        //searchController.searchBar.backgroundColor = [UIColor: Black]
        searchController.searchResultsUpdater = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // refresh Controller
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRefresh", forControlEvents:
            .ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        networkRequest()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //search bar display
        if searchController.active && searchController.searchBar.text != "" {
            return filterMovies!.count
        }
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //table view function that runs when an item is selected
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("item selected")
        print(indexPath)
        
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "all") {
        //filter data for search bar display
        filterMovies = movies!.filter { mov in return mov["title"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var movie = movies![indexPath.row]
        
        if searchController.active && searchController.searchBar.text != "" {
            movie = filterMovies![indexPath.row]
        }
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseURL = "http://image.tmdb.org/t/p/w500"
        
        if let posterView = movie["poster_path"] as? String
        {
            let imageURL = NSURL (string: baseURL + posterView)
            cell.posterView.setImageWithURL(imageURL!)
        }
        
        let rating = movie["vote_average"] as! NSNumber;
        let voteAverage = movie["vote_average"] as! NSNumber;
        let popularity = movie["popularity"] as! NSNumber;
        let voteString = voteAverage.stringValue + ".0";
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.ratingLabel.text = voteString[voteString.startIndex..<voteString.startIndex.advancedBy(3)];
        
        var color = UIColor(red: 0.27, green: 0.62, blue: 0.27, alpha: 1);
        switch(popularity.integerValue) {
        case 20..<40: color = UIColor(red: 0.223, green: 0.52, blue: 0.223, alpha: 1);
        case 10..<20: color = UIColor(red: 0.95, green: 0.6, blue: 0.071, alpha: 1);
        case 6..<10: color = UIColor(red: 0.90, green: 0.5, blue: 0.13, alpha: 1);
        case 5..<6: color = UIColor(red: 0.83, green: 0.33, blue: 0.33, alpha: 1);
        case 4..<5: color = UIColor(red: 0.91, green: 0.3, blue: 0.235, alpha: 1);
        case 0..<4: color = UIColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 1);
        default: break;
        }
        
        cell.ratingLabel.layer.backgroundColor = color.CGColor;
        cell.ratingLabel.layer.cornerRadius = 5;
        
        print("row\(indexPath.row)")
        return cell

            }
    
    func networkRequest() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            print(responseDictionary)
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.refreshControl.endRefreshing()
                            self.networkErrorView.hidden = true
                    }
                } else {
                    self.tableView.hidden = true
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
                    
                    self.tableView.hidden = false
                    print("Network error")
                }
        });
        task.resume()
        
    }
   
    func didRefresh() {
        networkRequest()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        var movie = movies![indexPath!.row]
        if searchController.active {
            movie = filterMovies![indexPath!.row]
        }
        // where the segue is going
        // casted as DetailViewController to make specific reference to custom class
        // allows us to access movie property of type NSDictionary
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        searchController.active = false
        
        // passing data from current movie variable to one in DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation