//
//  DetailViewController.swift
//  Project2
//
//  Created by Robert Whitehead on 10/18/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    

    var articleTitle : String = String()
    var articleImage : UIImage = UIImage()
    var articleSource : String = String()
    var articleDescription : String = String()
    var articleAuthor : String = String()
    var articleURL : String = String()
    var articlePublished : String = String()

    
    @IBOutlet var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        print("URL************** \(articleURL)")

        if let url0 = URL(string: articleURL) {
            let request = URLRequest(url: url0)
            
            webView.load(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        // get to the next screen
        self.performSegue(withIdentifier: "FacebookViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //    }
        //    func prepare(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "FacebookViewSegue") {
            let webViewController = segue.destination as! FacebookViewController
            
            webViewController.articleTitle = articleTitle
            webViewController.articleImage = articleImage
            webViewController.articleSource = articleSource
            webViewController.articleDescription = articleDescription
            webViewController.articleAuthor = articleAuthor
            webViewController.articleURL = articleURL
            webViewController.articlePublished = articlePublished
            
        }
        if (segue.identifier == "SaveDetailSegue") {
            let SaveViewController = segue.destination as!
            SaveTVController
            
            SaveViewController.articleTitle = articleTitle
            SaveViewController.articleImage = articleImage
            SaveViewController.articleSource = articleSource
            SaveViewController.articleDescription = articleDescription
            SaveViewController.articleAuthor = articleAuthor
            SaveViewController.articleURL = articleURL
            SaveViewController.articlePublished = articlePublished
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
