//
//  ViewController.swift
//  Concurrency
//
//  Created by Payal Gupta on 05/06/18.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    
    @IBOutlet weak var imageView7: UIImageView!
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var imageView9: UIImageView!
    
    @IBOutlet weak var imageView10: UIImageView!
    @IBOutlet weak var imageView11: UIImageView!
    @IBOutlet weak var imageView12: UIImageView!
    
    @IBOutlet weak var imageView13: UIImageView!
    @IBOutlet weak var imageView14: UIImageView!
    @IBOutlet weak var imageView15: UIImageView!


    var images = [
        "https://images.pexels.com/photos/590471/pexels-photo-590471.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        "https://images.pexels.com/photos/574282/pexels-photo-574282.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
        "https://images.pexels.com/photos/395132/pexels-photo-395132.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
    ]

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    //-----------Downloading - serial main queue, UI - serial main queue-----------
    @IBAction func loadOnMainQueue(_ sender: UIButton)
    {
        self.imageView1.image = Downloader.downloadImage(with: images[0])
        self.imageView2.image = Downloader.downloadImage(with: images[1])
        self.imageView3.image = Downloader.downloadImage(with: images[2])
    }
    
    //-----------Downloading - concurrent queue, UI - serial main queue-----------
    @IBAction func loadOnConcurrentQueue(_ sender: UIButton)
    {
        let concurrentQueue = DispatchQueue.global(qos: .default)
        concurrentQueue.async {
            let image = Downloader.downloadImage(with: self.images[0])
            DispatchQueue.main.async {
                self.imageView4.image = image
            }
        }
        concurrentQueue.async {
            let image = Downloader.downloadImage(with: self.images[1])
            DispatchQueue.main.async {
                self.imageView5.image = image
            }
        }
        concurrentQueue.async {
            let image = Downloader.downloadImage(with: self.images[2])
            DispatchQueue.main.async {
                self.imageView6.image = image
            }
        }
    }
    
    //-----------Downloading - serial queue, UI - serial main queue-----------
    @IBAction func loadOnSerialQueue(_ sender: UIButton)
    {
        let serialQueue = DispatchQueue(label: "com.pdiosdev.imagesQueue")
        serialQueue.async {
            let image = Downloader.downloadImage(with: self.images[0])
            DispatchQueue.main.async {
                self.imageView7.image = image
            }
        }
        serialQueue.async {
            let image = Downloader.downloadImage(with: self.images[1])
            DispatchQueue.main.async {
                self.imageView8.image = image
            }
        }
        serialQueue.async {
            let image = Downloader.downloadImage(with: self.images[2])
            DispatchQueue.main.async {
                self.imageView9.image = image
            }
        }
    }
    
    //-----------Downloading - operation queue, UI - serial main queue-----------
    @IBAction func loadWithOperationQueue(_ sender: UIButton)
    {
        let operationQueue = OperationQueue()
        operationQueue.addOperation {
            let image = Downloader.downloadImage(with: self.images[0])
            OperationQueue.main.addOperation {
                self.imageView10.image = image
            }
        }
        operationQueue.addOperation {
            let image = Downloader.downloadImage(with: self.images[1])
            OperationQueue.main.addOperation {
                self.imageView11.image = image
            }
        }
        operationQueue.addOperation {
            let image = Downloader.downloadImage(with: self.images[2])
            OperationQueue.main.addOperation {
                self.imageView12.image = image
            }
        }
    }
    
    //-----------Downloading - operation queue with dependencies, UI - serial main queue-----------
    @IBAction func loadWithOperationQueueWithDependency(_ sender: UIButton)
    {
        //P2, P3 is dependent on P1...P3 has high priority
        let operationQueue = OperationQueue()
        
        let operation1 = BlockOperation {
            let image = Downloader.downloadImage(with: self.images[0])
            OperationQueue.main.addOperation {
                self.imageView13.image = image
            }
        }
        operation1.completionBlock = { print("Operation-1 completed") }
        
        let operation2 = BlockOperation {
            let image = Downloader.downloadImage(with: self.images[1])
            OperationQueue.main.addOperation {
                self.imageView14.image = image
            }
        }
        operation2.queuePriority = .veryHigh
        operation2.completionBlock = { print("Operation-2 completed") }
        
        let operation3 = BlockOperation {
            let image = Downloader.downloadImage(with: self.images[2])
            OperationQueue.main.addOperation {
                self.imageView15.image = image
            }
        }
        operation3.addDependency(operation1)
        operation3.completionBlock = { print("Operation-3 completed") }
        
        operationQueue.addOperation(operation1)
        operationQueue.addOperation(operation2)
        operationQueue.addOperation(operation3)
    }
}

class Downloader
{
    static func downloadImage(with urlString: String) -> UIImage?
    {
        if let url = URL(string: urlString), let data = try? Data(contentsOf: url)
        {
            return UIImage(data: data)
        }
        return nil
    }
}
