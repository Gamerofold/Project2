//
//  MainViewController.swift
//  Project2
//
//  Created by Robert Whitehead on 10/17/17.
//  Copyright © 2017 Robert Whitehead. All rights reserved.
//

import UIKit
import SystemConfiguration
import UserNotifications

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Properties
    
//    // JSON Parsed
    var newsTitle :[String] = []
    var newsImagesURL :[String] = []
    var newsImages :[UIImage] = []
    var newsSource :[String] = []
    var newsDescription :[String] = []
    var newsAuthor :[String] = []
    var newsURL :[String] = []
    var newsPublished :[String] = []
    var newsKeywordHit :[Bool] = [] //Keyword Search hit
    //    // Newsapi.org URL request of JSON
    var newsRequestID :[String] = []
    var newsRequestName :[String] = []
    var newsRequestURL :[String] = []
    var newsRequestURLast :String = ""
    var newsRequestSelected :[Bool] = [] //flag Source selected
    var newsIndexOfRow :[Int] = []
    var newsRequestMax = 0 //count of requests
    var apiStatus = ""
    var newsHits = -1
    var newsRows = 1
    var iRowIndex = 0
    // keyword input box
    var keywordTextField : UITextField!
    var index : Int = 0
    var waitDispatchGroupFlag = false
    var waitDGFlagReload = false

    
    @IBOutlet var textField: UITextField!
    @IBOutlet var keywordQueryText: UITextField!
    

    @IBAction func queryBarButton(_ sender: UIBarButtonItem) {
        // make sure reload is finished using DispatchGroup
        textField.resignFirstResponder()
        keywordQueryText.resignFirstResponder()
        waitDGFlagReload = true
        if !waitDispatchGroupFlag {
            waitDGFlagReload = false
            iRowIndex = 0
            self.updateNewsList()
        }

    }
    
    @IBAction func searchBarButton(_ sender: UIBarButtonItem) {
        // make sure reload is finished using DispatchGroup
        textField.resignFirstResponder()
        keywordQueryText.resignFirstResponder()
        waitDGFlagReload = true
        if !waitDispatchGroupFlag {
            waitDGFlagReload = false
            iRowIndex = 0
            self.updateNewsList()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // notification OK
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAlllow, error in })

        textField.delegate = self
        keywordQueryText.delegate = self
        addKeywordSearch()

        //aaa.setToolbarItems.append(UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "onClickedToolbeltButton:")
        //    )
        
        // Setup Nav Title (iOS11 only)
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        //        let attributes = [NSAttributedStringKey.foregroundColor : UIColor.lightGray]
        //        navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
          
        tableView.register(UINib.init(nibName: "LoadingTVCell", bundle: nil), forCellReuseIdentifier: "LoadingMessageCell")
        tableView.register(UINib.init(nibName: "NewsImageTVCell", bundle: nil), forCellReuseIdentifier: "NewsImageCell")
        tableView.register(UINib.init(nibName: "HorzNewsImageTVCell", bundle: nil), forCellReuseIdentifier: "HorzNewsImageCell")
        
        // Update News List via JSON
        if newsHits < 0 {
            newsHits = 0
            self.initializeRequests()
            self.updateNewsList()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func shortcutSearchSetup(_ sender: UIBarButtonItem) {

    }
        func NetAlert () {
        //
        //        print("!")
        let alert = UIAlertController(title: "No Internet", message: "No Connection", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    //NSLog("The \"OK\" alert occured.")
                    fatalError("Network Connection Problem.")
                }))
// notification
            let noteContent = UNMutableNotificationContent()
            noteContent.title = "No Network"
            noteContent.subtitle = "No Internet"
            noteContent.body = "Check your Network Connection"
            noteContent.badge = 1
            
            let noteTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let noteRequest = UNNotificationRequest(identifier: "netDown", content: noteContent, trigger: noteTrigger)
            
            UNUserNotificationCenter.current().add(noteRequest, withCompletionHandler: nil)
//        
        self.present(alert, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        
        textField.resignFirstResponder()  //if desired
        //        performAction()
        print("return: \(textField.text ?? "")")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        print("textFieldDidBeginEditing \(textField.text)")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing: \(textField.text)")

        var compareSearch = textField.text?.lowercased() ?? ""
//        var compareSearch = keywordTextField.text?.lowercased() ?? ""
        // remove leading and trailing blanks
        var textCategory = "" //category search target
        if compareSearch != "" {
            if compareSearch.contains("&") {
                let searchTargets: [String] = compareSearch.components(separatedBy: "&")
                textCategory = searchTargets.first ?? ""
                compareSearch = searchTargets.last ?? ""
            }
            for _ in 0 ..< compareSearch.count {
                if compareSearch.first == " " {
                    compareSearch.removeFirst()
                }
                if compareSearch.last == " " {
                    compareSearch.removeLast()
                }
            }
            for _ in 0 ..< textCategory.count {
                if textCategory.first == " " {
                    textCategory.removeFirst()
                }
                if textCategory.last == " " {
                    textCategory.removeLast()
                }
            }
        }
        compareSearch.replacingOccurrences(of: ".|,|!|?|:|;|-|_|/|\\", with: " ")
        textCategory.replacingOccurrences(of: ".|,|!|?|:|;|-|_|/|\\", with: " ")
        newsHits = 0
        newsIndexOfRow = []
        for i in 0 ..< newsTitle.count {
            
            let textSearch : String = newsSource[i].lowercased() + " " + newsTitle[i].lowercased() + " " + newsDescription[i].lowercased()
            let textSource = newsSource[i].lowercased()
            textSearch.replacingOccurrences(of: ".|,|!|?|:|;|-|_|/|\\", with: " ")
            print(newsSource[i])
            if (compareSearch != "") {
                if (textSearch.range(of: compareSearch) != nil) {
                    if textCategory == "" {
                        newsKeywordHit[i] = true
                        newsHits += 1
                        //                        print("article:\(i) & \(newsTitle[i])")
                    } else {
                        if textCategory.range(of: textSource) != nil {
                            newsKeywordHit[i] = true
                            newsHits += 1
                            //                        print("article:\(i) & \(newsTitle[i])")
                        } else {
                            newsKeywordHit[i] = false
                        }
                    }
                    
                } else {
                    newsKeywordHit[i] = false
                }
            } else {
                if textCategory == "" {
                    newsKeywordHit[i] = true
                    newsHits += 1
                } else {
                    newsKeywordHit[i] = false
                }
            }
            if newsKeywordHit[i] {
                newsIndexOfRow.append(i)
            }
        }
        newsRows = newsHits
        if newsRows == 0 {
            newsRows = 1
        }
        self.tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsRows
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //       let cell = tableView.dequeueReusableCell(withIdentifier: "Bob", for: indexPath)
        let iRow = indexPath.row
        if iRow == 0 {
            iRowIndex = 0
        }
        
        //        if newsHits != 0 {
        //            iRowIndex = (iRow + ((iRow & 3) * 8)) % newsHits
        //        }
        //        print (iRow)
        
        var cellIdentifier = "LoadingMessageCell"
        if newsHits == 0 {
            guard let tCheck = keywordQueryText, tCheck.text != "" else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LoadingTVCell else {
                    fatalError("The dequeued cell is not an instance of LoadingMessageCell.")
                }
                return cell
            }
            cellIdentifier = "MainSetupCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MainListTVCell else {
                fatalError("The dequeued cell is not an instance of MainListCell.")
            }
            return cell
        } else {
            let iRowIndexTemp = iRowIndex
            for iNewRow in iRowIndexTemp ..< newsTitle.count {
                if !newsKeywordHit[iNewRow] {
                    iRowIndex += 1
                } else {
                    break
                }
            }
            iRowIndex = newsIndexOfRow[iRow]
            if (iRow / 2) % 2 == 0 {
                cellIdentifier = "HorzNewsImageCell"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HorzNewsImageTVCell else {
                    fatalError("The dequeued cell is not an instance of HorzNewsImageCell.")
                }
                if iRowIndex < newsImages.count {
                    cell.titleText.text = newsTitle[iRowIndex]
                    cell.sourceLabel.text = newsSource[iRowIndex]
                    cell.newsImage.image = newsImages[iRowIndex]
                    if iRow >= newsIndexOfRow.count {
                        newsIndexOfRow.append(iRowIndex)
                    } else {
                        newsIndexOfRow[iRow] = iRowIndex
                    }
                    iRowIndex += 1
                } else {
                    cell.titleText.text = ""
                    cell.sourceLabel.text = ""
                    cell.newsImage.image = nil
//                    cell.newsImage.image = newsImages[iRowIndex]
                }
                return cell
            } else {
                cellIdentifier = "NewsImageCell"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NewsImageTVCell else {
                    fatalError("The dequeued cell is not an instance of NewsImageCell.")
                }
                if iRowIndex < newsImages.count {
                    cell.titleText.text = newsTitle[iRowIndex]
                    cell.sourceLabel.text = newsSource[iRowIndex]
                    cell.newsImage.image = newsImages[iRowIndex]
                    if iRow >= newsIndexOfRow.count {
                        newsIndexOfRow.append(iRowIndex)
                    } else {
                        newsIndexOfRow[iRow] = iRowIndex
                    }
                    iRowIndex += 1
                } else {
                    cell.titleText.text = ""
                    cell.sourceLabel.text = ""
                    cell.newsImage.image = nil
//                    cell.newsImage.image = newsImages[iRowIndex]
                }
                return cell
            }
            // Configure the cell...
            //            return cell
            // Fetches the appropriate meal for the data source layout.
            
            //        cell.sampleLabel.text = "row: \(iRow)"
        }
        
        
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // add row action
    //
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        if newsIndexOfRow.count <= editActionsForRowAt.row {
            return []
        }
        index = newsIndexOfRow[editActionsForRowAt.row]
        
        let markfavorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
            //store your clicked row into index
            
            // get to the next screen
            self.performSegue(withIdentifier: "SaveViewSegue", sender: self)
            
        }
        markfavorite.backgroundColor = .lightGray
        
        let postfacebook = UITableViewRowAction(style: .normal, title: "Facebook\nPost") { action, index in
            // get to the next screen
            self.performSegue(withIdentifier: "FacebookSegue", sender: self)
        }
        postfacebook.backgroundColor = .blue
        
        let viewarticle = UITableViewRowAction(style: .normal, title: "View\nArticle") { action, index in
            
            // get to the next screen
            self.performSegue(withIdentifier: "DetailViewSegue", sender: self)
        }
        viewarticle.backgroundColor = .green
        
        //        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
        //            // Delete the row from the data source
        //            let delAlert = UIAlertController.self(title: "Project Delete", message: "Are you sure you want to delete this project?", preferredStyle: .alert)
        //            delAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
        //                //delete code
        //                tableView.deleteRows(at: [editActionsForRowAt], with: .fade)
        //            }))
        //            delAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        //            }))
        //            self.present(delAlert, animated: true, completion: nil)
        //
        //        }
        //        delete.backgroundColor = .red
        
        return [viewarticle, postfacebook, markfavorite]
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //store your clicked row into index
        index = indexPath.row
        if newsIndexOfRow.count > 0 {
        // get to the next screen
        self.performSegue(withIdentifier: "DetailViewSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if newsIndexOfRow.count < 1 {
            return
        }
        if index < 0 {
            index = 0
        }
            print("index:\(index)")
        
        if (segue.identifier == "DetailViewSegue") {
            let webViewController = segue.destination as! DetailViewController

            webViewController.articleTitle = newsTitle[index]
            webViewController.articleImage = newsImages[index]
            webViewController.articleSource = newsSource[index]
            webViewController.articleDescription = newsDescription[index]
            webViewController.articleAuthor = newsAuthor[index]
            webViewController.articleURL = newsURL[index]
            webViewController.articlePublished = newsPublished[index]

        }

        if (segue.identifier == "SaveViewSegue") {
            let SaveViewController = segue.destination as! SaveTVController
            
            SaveViewController.articleTitle = newsTitle[index]
            SaveViewController.articleImage = newsImages[index]
            SaveViewController.articleSource = newsSource[index]
            SaveViewController.articleDescription = newsDescription[index]
            SaveViewController.articleAuthor = newsAuthor[index]
            SaveViewController.articleURL = newsURL[index]
            SaveViewController.articlePublished = newsPublished[index]

        }
        
        if (segue.identifier == "FacebookSegue") {
            let FBViewController = segue.destination as! FacebookViewController
            
            FBViewController.articleTitle = newsTitle[index]
            FBViewController.articleImage = newsImages[index]
            FBViewController.articleSource = newsSource[index]
            FBViewController.articleDescription = newsDescription[index]
            FBViewController.articleAuthor = newsAuthor[index]
            FBViewController.articleURL = newsURL[index]
            FBViewController.articlePublished = newsPublished[index]
            
        }
    }
    // MARK: Add Toolbar with keyword search
    func addKeywordSearch() {
        // = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
//        self.navigationController?.isToolbarHidden = false
        //        self.navigationController?.toolbar.barPosition = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        var items = [UIBarButtonItem]()
        //        items.append( UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) )
        
        //Text
        let text = UIBarButtonItem(title: "⚙️ Tom's API \"q\":", style: UIBarButtonItemStyle.plain, target: self, action: #selector(shortcutSearchSetup(_:)))
        
        text.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20.0),
            NSAttributedStringKey.foregroundColor : UIColor.black], for: [.normal])
        
        items.append(text)
        navigationController?.toolbar.backgroundColor = UIColor.blue
        
        //TextField
        keywordTextField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.width - 200, height: 30))//(0,0,150,30))
        keywordTextField.delegate = self as? UITextFieldDelegate
        let border = CALayer()
        let width : CGFloat = 2.0
        keywordTextField.placeholder = "Enter API query"
        keywordTextField.text = ""
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: keywordTextField.frame.size.height-width, width: keywordTextField.frame.size.width, height: keywordTextField.frame.size.height)
        border.borderWidth = width
        keywordTextField.layer.addSublayer(border)
        keywordTextField.layer.masksToBounds = true
        let keywordTextFieldButton = UIBarButtonItem(customView: keywordTextField)
        items.append(keywordTextFieldButton)
        
        self.toolbarItems = items // this made the difference. setting the items to the controller, not the navigationcontroller
    }
    // MARK: Networking
    
    func updateNewsList() {
        // clear news lists
        self.newsTitle = []
        self.newsImagesURL = []
        self.newsImages = []
        self.newsSource = []
        self.newsDescription = []
        self.newsAuthor = []
        self.newsURL = []
        self.newsPublished = []
        self.newsHits = 0
        let q = keywordQueryText.text! + newsRequestURLast //keywordTextField.text! + newsRequestURLast
            let jsonDispatchGroup = DispatchGroup()
            waitDispatchGroupFlag = true
            newsIndexOfRow = []
        if !isConnectedToNetwork() {
            NetAlert()
        }
        for iRequestIndex in 0 ..< newsRequestMax {
            
            // Setup the URL Request...
            
            let urlString = newsRequestURL[iRequestIndex]  + q
            let requestUrl = URL(string:urlString)
            let request = URLRequest(url:requestUrl!)
            jsonDispatchGroup.enter()
            
            // Setup the URL Session...
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                
                // Process the Response...
                let httpResponse = response as? HTTPURLResponse
                let statusCode = httpResponse?.statusCode
                print("Status Code for HTTP Response is: \(String(describing: statusCode)) \n")
                
                if statusCode != 200 {
                    print("Data request failed :-(")
                    return
                }
                
                if error == nil,let usableData = data {
                    print("JSON Received...File Size: \(usableData) \n")
                    //ready for JSONSerialization
                    
                    // Serialize the JSON Data
                    do {
                        
                        // Serialize....
                        let object = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        //print(object)
                        // Do Something with the serialized data...
                        if let dictionary = object as? [String: AnyObject] {
                            //                            print(dictionary)
                            //                            if let status = dictionary["status"] as? [String: AnyObject] {
                            //
                            //                                for stat in status {
                            //                                    self.apiStatus = stat.value as! String
                            //                                    if self.apiStatus != "ok" {
                            //                                        // API Error and Alert User
                            //                                        print("API Access Error: \(String(self.apiStatus))")
                            //                                    }
                            //                                    print("******status: \(status)")
                            //                                }
                            //
                            //                            }
                            
                            if let articles = dictionary["articles"] as? [[String: AnyObject]] {
                                //                                print("Articles:")
                                //                                print(articles)
                                for article in articles {
                                    
                                    if let author = article["author"] as? String {
                                        self.newsAuthor.append(author)
                                    } else {
                                        self.newsAuthor.append("")
                                    }
                                    if let title = article["title"] as? String {
                                        self.newsTitle.append(title)
                                    } else {
                                        self.newsTitle.append("")
                                    }
                                    if let description = article["description"] as? String {
                                        self.newsDescription.append(description)
                                    } else {
                                        self.newsDescription.append("")
                                    }
                                    if let url = article["url"] as? String {
                                        self.newsURL.append(url)
                                    } else {
                                        self.newsURL.append("")
                                    }
                                    if let urlToImage = article["urlToImage"] as? String {
                                        self.newsImagesURL.append(urlToImage)
                                    } else {
                                        self.newsImagesURL.append("")
                                    }
                                    if let publishedAt = article["publishedAt"] as? String {
                                        self.newsPublished.append(publishedAt)
                                    } else {
                                        self.newsPublished.append("")
                                    }
                                    let source = self.newsRequestName[iRequestIndex]
                                    self.newsSource.append(source)
                                    self.newsIndexOfRow.append(self.newsHits)
                                    self.newsKeywordHit.append(true) //keywordHits)
                                    var tPhoto = UIImage(named: "defaultPhoto")
                                    if self.newsImagesURL.count > self.newsHits {
                                        let tURL = self.newsImagesURL[self.newsHits]
                                        if let url0 = URL(string: tURL),
                                            let ImageData: NSData = NSData(contentsOf: url0) {
                                        tPhoto = UIImage(data: ImageData as Data)
                                    }
                                    }
                                    
                                    self.newsHits += 1
                                    self.newsRows = self.newsHits
                                    
                                    
                                    guard let newsImage = tPhoto else {
                                        fatalError("Unable to instantiate newsImage photo")
                                    }
                                    self.newsImages.append(newsImage)
                                    
                                }
                            }
                        }
                        
                        print("Found request:\(iRequestIndex)")
                        
                        // Reload the table view...
                        DispatchQueue.main.async() {
                            self.tableView.reloadData()
                        }
                        jsonDispatchGroup.leave()
                        
                        
                        // Else take care of JSON Serializing error
                    } catch {
                        // Handle Error and Alert User
                        print("Error deserializing JSON: \(error)")
                    }
                    
                    
                    // Else take care of Networking error
                } else {
                    // Handle Error and Alert User
                    print("Networking Error: \(String(describing: error) )")
                }
                
            }
            // Execute the URL Task
            task.resume()
            

        }
        
        // bring in images from URLs
        //        for i in 0 ..< self.newsImagesURL.count {
        //            let tURL = self.newsImagesURL[i]
        //
        //            var tPhoto = UIImage(named: "defaultPhoto")
        //            if let url0 = URL(string: tURL),
        //                let ImageData: NSData = NSData(contentsOf: url0) {
        //                tPhoto = UIImage(data: ImageData as Data)
        //            }
        //            guard let newsImage = tPhoto else {
        //                fatalError("Unable to instantiate newsImage photo")
        //            }
        //            newsImages[i] = newsImage
        //
        //        }
        jsonDispatchGroup.notify(queue: .main, execute: {
            print("End Dispatch")
            if self.waitDGFlagReload {
                self.waitDGFlagReload = false
                self.iRowIndex = 0
                self.updateNewsList()
            }
            self.waitDispatchGroupFlag = false
        })
    }

    

    
    // MARK: Defaults
    // API calls
    
    func initializeRequests() {
        // clear requests
        self.newsRequestID = []
        self.newsRequestName = []
        self.newsRequestURL = []
        self.newsRequestSelected = []
        // init requests
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("associated-press")
        self.newsRequestName.append("Associated Press")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=associated-press&q=") //&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
//        self.newsRequestURL.append("https://newsapi.org/v1/articles?source=associated-press&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("espn")
        self.newsRequestName.append("ESPN")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=espn&q=") //&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
//        self.newsRequestURL.append("https://newsapi.org/v1/articles?source=espn&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("the-washington-post")
        self.newsRequestName.append("The Washington Post")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=the-washington-post&q=") //&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
//        self.newsRequestURL.append("https://newsapi.org/v1/articles?source=the-washington-post&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("engadget")
        self.newsRequestName.append("Engadget")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=engadget&q=") //&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
//        self.newsRequestURL.append("https://newsapi.org/v1/articles?source=engadget&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("buzzfeed")
        self.newsRequestName.append("Buzzfeed")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=buzzfeed&q=") //&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
////        self.newsRequestURL.append("https://newsapi.org/v1/articles?source=buzzfeed&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d")
//        self.newsRequestSelected.append(true)
//        self.newsRequestID.append("abc-news")
//        self.newsRequestName.append("ABC News")
//        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=abc-news&q=")
        
        self.newsRequestSelected.append(true)
        self.newsRequestID.append("cnn")
        self.newsRequestName.append("CNN")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=cnn&q=")

        self.newsRequestSelected.append(true)
        self.newsRequestID.append("the-new-york-times")
        self.newsRequestName.append("The New York Times")
        self.newsRequestURL.append("http://beta.newsapi.org/v2/top-headlines?sources=the-new-york-times&q=")
        
        self.newsRequestURLast = "&sortBy=top&apiKey=99cda128d58f4870b181e4806bb73d0d"
        
        self.newsRequestMax = newsRequestID.count
    }

/*
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        print("vc")
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //
    // iOS Network Reachabiity
    //
    
    //
    // Set this function up to check if newtork is reachable before calling URLSession task...
    //
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
        
    }

}
