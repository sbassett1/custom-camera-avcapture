//
//  CapturedImageViewController.swift
//  CustomCamera
//
//  Created by Stephen Bassett on 5/18/19.
//  Copyright © 2019 Stephen Bassett. All rights reserved.
//

import UIKit

class CapturedImageViewController: UIViewController {
    
    @IBOutlet var capturedImageView: UIImageView!
    
    var capturedImage: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.capturedImage {
            self.capturedImageView.image = UIImage(data: image)
        }
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
