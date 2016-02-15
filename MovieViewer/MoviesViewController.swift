//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Donatea Zefi on 2/14/16.
//  Copyright © 2016 Donatea Zefi. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var filteredMovies : [NSDictionary]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            
                          self.movies = responseDictionary["results"] as? [NSDictionary]
                          self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
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
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            filteredMovies = movies
        } else {
            filteredMovies = movies?.filter({(dataItem : NSDictionary) -> Bool in
                let title = dataItem["title"] as! String
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        filteredMovies = movies
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies! [indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue called")
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
