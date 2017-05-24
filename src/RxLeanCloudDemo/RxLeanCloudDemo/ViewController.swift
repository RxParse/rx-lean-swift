//
//  ViewController.swift
//  RxLeanCloudDemo
//
//  Created by WuJun on 24/05/2017.
//  Copyright © 2017 LeanCloud. All rights reserved.
//

import UIKit
import RxSwift
import RxLeanCloudSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showMessage() {
        let alertController = UIAlertController(title: "Welcome to My First App", message: "Hello World", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)

        let todo = RxAVObject(className: "SwiftTodo")
        todo["foo"] = "bar"

        todo.save().map { (avObject) -> String in
            return avObject.objectId
        }.observeOn(MainScheduler.instance).subscribe({ print($0) })
    }


}

