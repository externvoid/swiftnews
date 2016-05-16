import UIKit

class ViewController: UITableViewController {
    // エントリーの配列
    var entries = NSMutableArray()
    
    // ニュースサイトの配列を作る
    let newsUrlStrings = [
        "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http://rss.rssad.jp/rss/impresswatch/pcwatch.rdf&num=8", 
        "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http://rss.itmedia.co.jp/rss/2.0/news_bursts.xml&num=8", 
        "http://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http://jp.techcrunch.com/feed/&num=8", 
    ]
    
    // 画像ファイル名の配列を作る
    let imageNames = [
        "pcwatch", 
        "itmedia", 
        "techcrunch", 
    ]
    override func viewDidLoad() {
      self.refresh(self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detail" {
            let detailController = segue.destinationViewController as! DetailController
            detailController.entry = sender as! NSDictionary
        }
    }

    @IBAction func refresh(sender: AnyObject) {
        // エントリーを全て削除する
        entries.removeAllObjects()
        
        // ニュースサイトの配列からアドレスを取り出す
        for newsUrlString in newsUrlStrings {
            // データのダウンロードを行う
            let url = NSURL(string: newsUrlString)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, response, error in 
                // JSONデータを辞書に変換する
              let dict = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                
                // /responseData/feed/entriesを取得する
              guard let responseData = dict["responseData"] as? NSDictionary else {return}
              guard let feed = responseData["feed"] as? NSDictionary else {return}
              guard let entries = feed["entries"] as? NSArray else{return}
              // NSDateFormatterのインスタンスを作る
              let formatter = NSDateFormatter()
                formatter.locale = NSLocale(localeIdentifier: "en-US")
                formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzzz"
                
              // エントリーに情報を追加する
              for var i = 0; i < entries.count; i++ {
                  // エントリーを取り出す
                  let entry = entries[i] as! NSMutableDictionary
                  
                  // ニュースサイトのURLを追加する
                  entry["url"] = newsUrlString
                  
                  // NSDate型の日付を追加する
                  let dateStr = entry["publishedDate"] as! String
                  let date = formatter.dateFromString(dateStr)
                  entry["date"] = date
              }
              
              // エントリーを配列に追加する
              self.entries.addObjectsFromArray(entries as [AnyObject])
              
              // エントリーをソートする
              self.entries.sortUsingComparator({ object1, object2 in 
                  // 日付を取得する
                  let date1 = object1["date"] as! NSDate
                  let date2 = object2["date"] as! NSDate
                  
                  // 日付を比較する
                  let order = date1.compare(date2)
                  
                  // 比較結果をひっくり返す
                  if order == NSComparisonResult.OrderedAscending {
                      return NSComparisonResult.OrderedDescending
                  }
                  else if order == NSComparisonResult.OrderedDescending {
                      return NSComparisonResult.OrderedAscending
                  }
                  return order
              })
              
              // テーブルビューの更新をするため、メインスレッドにスイッチする
              dispatch_async(dispatch_get_main_queue(), {
                  // テーブルビューの更新をする
                  self.tableView.reloadData()
              })
            }) // end of dataTaskWithRL method
            task.resume() // let task = , task.resume()ただコレだけ
        } // end of newsUrlString for-loop, スレッドを3つ生成する
    }
  func makeCell(cell: UITableViewCell, _ entry: NSDictionary){
//  func makeCell(cell: UITableViewCell, _ entry: AnyObject){
    cell.viewWithTag(1)
    let titleLabel = cell.viewWithTag(1) as! UILabel
    //titleLabel.text = "title"
    titleLabel.text = entry["title"] as? String
  }
}


extension ViewController { //❶総エントリー数を返す、❷cellを返す、❸タップして遷移
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // エントリーの数を返す
        return entries.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // セルを取得する
        var cell: UITableViewCell
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("top")! as UITableViewCell
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier("news")! as UITableViewCell
        }
        
        // エントリーを取得する
        let entry = entries[indexPath.row] as! NSDictionary
        //
        // cellを構成するGUI部品はviewWithTag(1, 2, 3, 4)で取得
        // GUI部品への値設定は、makeCell(entry, cell)で行えるか？
        // entry: NSMutableArrayから取り出した要素, NSDictionary
        // タイトルラベルを取得して、タイトルを設定する
//        let titleLabel = cell.viewWithTag(1) as! UILabel
//        titleLabel.text = entry["title"] as? String
        makeCell(cell, entry)
        
        // 本文ラベルを取得して、本文を設定する
        let descriptionLabel = cell.viewWithTag(2) as! UILabel
        descriptionLabel.text = entry["contentSnippet"] as? String
        let htmlString = entry["contentSnippet"] as? String
      // de-sanitize サニタイズ
      //- initWithData:options:documentAttributes:error:
      let astr = try! NSAttributedString(data:
        htmlString!.dataUsingEncoding(NSUnicodeStringEncoding)!,
        options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
        documentAttributes: nil)
      descriptionLabel.text = astr.string
  //    descriptionLabel.text = entry["contentSnippet"] as? String
  
        // NSDateFormatterを作って、日付を文字列に変換する
        let date = entry["date"] as! NSDate
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja-JP")
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        let dateStr = formatter.stringFromDate(date)
        
        // 日付ラベルを取得して、日付を設定する
        let dateLabel = cell.viewWithTag(3) as! UILabel
        dateLabel.text = dateStr
        
        // 画像ファイル名を決定して、UIImageを作る
        let urlString = entry["url"] as! String
        let index = newsUrlStrings.indexOf(urlString)
        let imageName = imageNames[index!]
        let image = UIImage(named: imageName)
        
        // イメージビューを取得して、画像を設定する
        let imageView = cell.viewWithTag(4) as! UIImageView
        imageView.image = image
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detail", sender: entries[indexPath.row])
    }
}

//逆サニタイズ：スペースが&nbsp(non-breakable space)に変換された文字列が取得できる。サニタイズ後の文字列が取得できているのだ。それを、サニタイズ前の状態に戻すには、NSAttributedStringオブジェクトへ変換した後に、文字列を取り出す。
//ただし、htmlString!.dataUsingEncoding(NSUnicodeStringEncoding)!と言った具合に、NSAttributedStringにはNSDataを与える。
