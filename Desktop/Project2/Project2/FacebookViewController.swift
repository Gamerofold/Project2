//
//  FacebookViewController.swift
//  Project2
//
//  Created by Robert Whitehead on 10/18/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit

class FacebookViewController: UIViewController {

    var articleTitle : String = String()
    var articleImage : UIImage = UIImage()
    var articleSource : String = String()
    var articleDescription : String = String()
    var articleAuthor : String = String()
    var articleURL : String = String()
    var articlePublished : String = String()
    
    @IBOutlet var titleText: UITextView!
    @IBOutlet var photoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        photoImage.image = articleImage
        titleText.text = articleTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
