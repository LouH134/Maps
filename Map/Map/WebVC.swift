//
//  WebVC.swift
//  Map
//
//  Created by Louis Harris on 5/17/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import WebKit

class WebVC: UIViewController
{
    var url : String?
    @IBOutlet weak var webView: UIWebView!
    
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
