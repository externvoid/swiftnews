//
//  DetailController.swift
//  SwiftNews
//
//  Created by Makoto Kinoshita on 2014/09/23.
//  Copyright (c) 2014年 HMDT CO., Ltd. All rights reserved.
//

import UIKit
import Social

class DetailController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    var entry: NSDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: self.entry["link"] as! String)!
        webView.loadRequest(NSURLRequest(URL: url))
    }
    
    @IBAction func twitter(sender: AnyObject) {
        // Twitterへの投稿が使えるかどうか確認
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            // コントローラを作る
            let controller = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            // リンクを追加する
            let link = entry["link"] as! String
            let url = NSURL(string: link)
            controller.addURL(url)
            
            // テキストを追加する
            let title = entry["title"] as! String
            controller.setInitialText(title)
            
            // 投稿画面を表示する
            presentViewController(controller, animated: true, completion: {})
        }
    }
    
    @IBAction func facebook(sender: AnyObject) {
        // Facebookへの投稿が使えるかどうか確認
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            // コントローラを作る
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            // リンクを追加する
            let link = entry["link"] as! String
            let url = NSURL(string: link)
            controller.addURL(url)
            
            // テキストを追加する
            let title = entry["title"] as! String
            controller.setInitialText(title)
            
            // 投稿画面を表示する
            presentViewController(controller, animated: true, completion: {})
        }
    }
}
