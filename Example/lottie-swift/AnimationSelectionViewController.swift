//
//  AnimationSelectionViewController.swift
//  lottie-swift
//
//  Created by Antonio Anchondo on 6/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import UIKit
final class AnimationSelectionViewController : UITableViewController {
    var animations = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundle = Bundle.main
        guard let resourcePath = bundle.resourcePath  else {
            return
        }

        let animationsPath = resourcePath + "/TestAnimations"
        guard let files = FileManager.default.enumerator(atPath: animationsPath) else {
            return
        }
        animations = files
            .compactMap{ $0 as? String }
            .filter {$0 != "TypeFace" }
            .map{ $0.replacingOccurrences(of: ".json", with: "") }

        title = "Select animation"
    }

    //MARK: - TableView DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        animations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "a")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "a")
        }
        cell!.textLabel?.text = animations[indexPath.row]
        return cell!
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController  = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        let name =  animations[indexPath.row].split(separator: "\\")

        viewController.animationName = String(name[0])
        viewController.subdirectory = "TestAnimations" + ( name.count == 2 ? "" : "\\\(name[1])")

        navigationController?.pushViewController(viewController, animated: true)
    }
}
