//
//  WebVC.swift
//  GoogleMap
//
//  Created by Louis Harris on 6/1/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import WebKit

class WebVC:UIViewController
{
    @IBOutlet weak var webView: UIWebView!
    var url:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadURL()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadURL()
    {
        self.webView.bounds = UIScreen.main.bounds
        
        let selectedURL = URL(string: self.url!)
        self.webView.loadRequest(URLRequest(url: selectedURL!))
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
