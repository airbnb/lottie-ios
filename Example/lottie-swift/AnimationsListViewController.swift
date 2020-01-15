//
//  AnimationsListViewController.swift
//  lottie-swift_Example
//
//  Created by Vladislav Maltsev on 15.01.2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class AnimationsListViewController: UITableViewController {
    private var animations: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let animationsDirectory = Bundle.main.resourceURL?.appendingPathComponent("TestAnimations") else { return }
        let fileManager = FileManager.default
        let animationFiles = (try? fileManager.contentsOfDirectory(atPath: animationsDirectory.path)) ?? []
        animations = animationFiles
            .filter { $0.hasSuffix(".json") }
            .sorted()
            .map { ($0 as NSString).deletingPathExtension }
        tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        animations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimationCell", for: indexPath)
        cell.textLabel?.text = animations[indexPath.item]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let playerViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController
        else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }

        playerViewController.animationName = animations[indexPath.item]
        navigationController?.pushViewController(playerViewController, animated: true)
    }
}
