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
    public var otherInfoPair: OtherInfoPair?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let otherInfoPair = otherInfoPair else { return }
        textView.attributedText = attributedString(fromHtml: otherInfoPair.fulltext)
    }
}

// MARK: Helpers
extension MoreInfoViewController {
    
    func attributedString(fromHtml html: String) -> NSAttributedString? {
        do {
            let data = html.data(using: String.Encoding.unicode, allowLossyConversion: true)!
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
            return try NSAttributedString(data: data, options: options, documentAttributes: nil)
        } catch {
            print(error)
            return nil
        }
    }
}

