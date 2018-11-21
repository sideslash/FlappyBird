//
//  GameViewController.swift
//  FlappyBird
//
//  Created by LingNanTong on 2017/7/4.
//
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    if let view = self.view as! SKView? {
      let scene = GameScene(size: view.bounds.size)
      scene.scaleMode = .aspectFill
      view.presentScene(scene)
      
      view.ignoresSiblingOrder = true
//      view.showsPhysics = true
      view.showsFPS = true
      view.showsNodeCount = true
    }
  }

  override var shouldAutorotate: Bool {
      return true
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
      if UIDevice.current.userInterfaceIdiom == .phone {
          return .allButUpsideDown
      } else {
          return .all
      }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Release any cached data, images, etc that aren't in use.
  }

  override var prefersStatusBarHidden: Bool {
      return true
  }
}
