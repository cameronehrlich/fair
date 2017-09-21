//
//  MoreInfoViewController.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/20/17.
//  Copyright © 2017 fair. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var otherInfoPair: OtherInfoPair?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let otherInfoPair = otherInfoPair {
            do {
                textView.attributedText = try NSAttributedString(data: otherInfoPair.fulltext.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                print(error)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

