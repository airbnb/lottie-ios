//
//  ViewController.swift
//  Lottie-Example-Swift
//
//  Created by brandon_withrow on 1/4/18.
//  Copyright © 2018 brandon_withrow. All rights reserved.
//

import UIKit
import Lottie

class ViewController: UIViewController, URLSessionDownloadDelegate {

  private var downloadTask: URLSessionDownloadTask?
  private var boatAnimation: LOTAnimationView?
  var downloadProgress: Float = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()

    // Create Boat Animation
    boatAnimation = LOTAnimationView(name: "Boat_Loader")
    // Set view to full screen, aspectFill
    boatAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    boatAnimation!.contentMode = .scaleAspectFill
    boatAnimation!.frame = view.bounds
    // Add the Animation
    view.addSubview(boatAnimation!)

    let button = UIButton(type: .system)
    button.setTitle("Start Download", for: .normal)
    button.sizeToFit()
    button.center = view.center
    button.addTarget(self, action: #selector(startDownload(button:)), for: .touchUpInside)
    view.addSubview(button)

    let boatEndPoint = boatAnimation!.convert(CGPoint(x:view.bounds.midX, y:-view.bounds.midY), toKeypathLayer: LOTKeypath(string: "Boat"))
    let boatStartPoint = boatAnimation!.convert(CGPoint(x:view.bounds.midX, y:view.bounds.midY), toKeypathLayer: LOTKeypath(string: "Boat"))
    let diff = boatStartPoint.y - boatEndPoint.y

    let pointCallBack: LOTPointValueCallback  = LOTPointValueCallback { [weak self] (startFrame, endFrame, startPoint, endPoint, interpolatedPoint, interpolatedProgress, currentFrame) -> CGPoint in
      let y = interpolatedPoint.y - (CGFloat(self!.downloadProgress) * diff)
      return CGPoint(x: interpolatedPoint.x, y: y)
    }

    boatAnimation!.setValueCallback(pointCallBack, for: LOTKeypath(string: "Boat.Transform.Position"))

    //Play the first portion of the animation on loop until the animation finishes.
    boatAnimation!.loopAnimation = true
    boatAnimation!.play(fromProgress: 0,
                        toProgress: 0.5,
                        withCompletion: nil)

  }

  @objc func startDownload(button: UIButton) {
    button.isHidden = true
    createDownloadTask()
  }

  func createDownloadTask() {
    let downloadRequest = URLRequest(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/8/8f/Whole_world_-_land_and_oceans_12000.jpg")!)
    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)

    downloadTask = session.downloadTask(with:downloadRequest)
    downloadTask!.resume()
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    print("Download finished")
    boatAnimation!.pause()
    boatAnimation!.loopAnimation = false
    boatAnimation!.animationSpeed = 4

    boatAnimation!.play(toProgress: 0.5) {[weak self] (_) in
      self?.boatAnimation!.animationSpeed = 1
      self?.boatAnimation!.play(toProgress: 1, withCompletion: nil)
    }
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
  }

}

