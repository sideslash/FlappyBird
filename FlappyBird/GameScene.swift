//
//  GameScene.swift
//  FlappyBird
//
//  Created by LingNanTong on 2017/7/4.
//
//

import SpriteKit

let birdCategory: UInt32 = 0x1 << 0
let pipeCategory: UInt32 = 0x1 << 1
let floorCategory: UInt32 = 0x1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate {

  enum GameStatus {
    case idle
    case running
    case over
  }

  var gameStatus: GameStatus = .idle
  
  var floor1: SKSpriteNode!
  var floor2: SKSpriteNode!
  
  var bird: SKSpriteNode!

  lazy var gameOverLabel: SKLabelNode = {
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = "Game Over"
    return label
  }()
  
  lazy var metersLabel: SKLabelNode = {
    let label = SKLabelNode(text: "meters:0")
    label.verticalAlignmentMode = .top
    label.horizontalAlignmentMode = .center

    return label
  }()
  
  var meters = 0 {
    didSet {
      metersLabel.text = "meters:\(meters)"
    }
  }
  
  override func didMove(to view: SKView) {
    self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    
    // Set Scene physics
    self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    self.physicsWorld.contactDelegate = self
    
    // Set Meter Label
    metersLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
    metersLabel.zPosition = 100
    addChild(metersLabel)
    
    // Set floors
    floor1 = SKSpriteNode(imageNamed: "floor")
    floor1.anchorPoint = CGPoint(x: 0, y: 0)
    floor1.position = CGPoint(x: 0, y: 0)
    floor1.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor1.size.width, height: floor1.size.height))
    floor1.physicsBody?.categoryBitMask = floorCategory
    addChild(floor1)
    floor2 = SKSpriteNode(imageNamed: "floor")
    floor2.anchorPoint = CGPoint(x: 0, y: 0)
    floor2.position = CGPoint(x: floor1.size.width, y: 0)
    floor2.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: floor2.size.width, height: floor2.size.height))
    floor2.physicsBody?.categoryBitMask = floorCategory
    addChild(floor2)
    
    // Set bird
    bird = SKSpriteNode(imageNamed: "player1")
    bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
    bird.physicsBody?.allowsRotation = false
    bird.physicsBody?.categoryBitMask = birdCategory
    bird.physicsBody?.contactTestBitMask = floorCategory | pipeCategory
    addChild(bird)
    
    shuffle()
  }
  
  func shuffle() {

    gameStatus = .idle
    
    meters = 0
    gameOverLabel.removeFromParent()
    removeAllPipesNode()
    
    bird.physicsBody?.isDynamic = false
    bird.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
    birdStartFly()
  }
  
  func startGame() {
    gameStatus = .running
    
    bird.physicsBody?.isDynamic = true
    startCreateRandomPipesAction()
  }
  
  func gameOver() {
    
    gameStatus = .over
    
    birdStopFly()
    stopCreateRandomPipesAction()

    isUserInteractionEnabled = false
    
    addChild(gameOverLabel)
    gameOverLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height)
    gameOverLabel.run(SKAction.move(by: CGVector(dx:0, dy:-self.size.height * 0.5), duration: 0.5), completion: {
      self.isUserInteractionEnabled = true
    })
  }
  
  func birdStartFly() {
    let flyAction = SKAction.animate(with: [SKTexture(imageNamed: "player1"),
                                            SKTexture(imageNamed: "player2"),
                                            SKTexture(imageNamed: "player3"),
                                            SKTexture(imageNamed: "player2")],
                                     timePerFrame: 0.15)
    bird.run(SKAction.repeatForever(flyAction), withKey: "fly")
  }
  
  func birdStopFly() {
    bird.removeAction(forKey: "fly")
  }
  
  func moveScene() {
    
    //make floor move
    floor1.position = CGPoint(x: floor1.position.x - 1, y: floor1.position.y)
    floor2.position = CGPoint(x: floor2.position.x - 1, y: floor2.position.y)
    
    //check floor position
    if floor1.position.x < -floor1.size.width {
      floor1.position = CGPoint(x: floor2.position.x + floor2.size.width, y: floor1.position.y)
    }
    if floor2.position.x < -floor2.size.width {
      floor2.position = CGPoint(x: floor1.position.x + floor1.size.width, y: floor2.position.y)
    }
    
    //make pipe move
    for pipeNode in self.children where pipeNode.name == "pipe" {
      if let pipeSprite = pipeNode as? SKSpriteNode {
        pipeSprite.position = CGPoint(x: pipeSprite.position.x - 1, y: pipeSprite.position.y)
        if pipeSprite.position.x < -pipeSprite.size.width * 0.5 {
          pipeSprite.removeFromParent()
        }
      }
    }
  }
  
  
  func startCreateRandomPipesAction() {
    let waitAct = SKAction.wait(forDuration: 3.5, withRange: 1.0)
    let generatePipeAct = SKAction.run {
      self.createRandomPipes()
    }
    run(SKAction.repeatForever(SKAction.sequence([waitAct, generatePipeAct])), withKey: "createPipe")
  }
  
  func stopCreateRandomPipesAction() {
    self.removeAction(forKey: "createPipe")
  }
  
  func removeAllPipesNode() {
    for pipe in self.children where pipe.name == "pipe" {
      pipe.removeFromParent()
    }
  }
  
  func createRandomPipes() {
    
    //地板到顶部总高度
    let height = self.size.height - self.floor1.size.height
    
    //上下管道中间的空档
    let pipeGap = CGFloat(arc4random_uniform(UInt32(bird.size.height))) + bird.size.height * 2.5
    
    //管道宽度在60-80之间取随机数
    //    let pipeWidth = CGFloat(arc4random_uniform(20) + 60)
    let pipeWidth = CGFloat(60.0)
    
    //随机计算上部pipe高度
    let topPipeHeight = CGFloat(arc4random_uniform(UInt32(height - pipeGap)))
    //总高度减去gap高度减去topPipe高度剩下九尾bottomPipe高度
    let bottomPipeHeight = height - pipeGap - topPipeHeight
    
    addPipes(topSize: CGSize(width: pipeWidth, height: topPipeHeight), bottomSize: CGSize(width: pipeWidth, height: bottomPipeHeight))
  }
  
  
  func addPipes(topSize: CGSize, bottomSize: CGSize) {
    let topTexture = SKTexture(imageNamed: "topPipe")
    let topPipe = SKSpriteNode(texture: topTexture, size: topSize)
    topPipe.physicsBody = SKPhysicsBody(texture: topTexture, size: topSize)
    topPipe.physicsBody?.isDynamic = false
    topPipe.physicsBody?.categoryBitMask = pipeCategory
    topPipe.name = "pipe"
    topPipe.position = CGPoint(x: self.size.width + topPipe.size.width * 0.5, y: self.size.height - topPipe.size.height * 0.5)
    
    let bottomTexture = SKTexture(imageNamed: "bottomPipe")
    let bottomPipe = SKSpriteNode(texture: bottomTexture, size: bottomSize)
    bottomPipe.physicsBody = SKPhysicsBody(texture: bottomTexture, size: bottomSize)
    bottomPipe.physicsBody?.isDynamic = false
    bottomPipe.physicsBody?.categoryBitMask = pipeCategory
    bottomPipe.name = "pipe"
    bottomPipe.position = CGPoint(x: self.size.width + bottomPipe.size.width * 0.5, y: self.floor1.size.height + bottomPipe.size.height * 0.5)
    
    addChild(topPipe)
    addChild(bottomPipe)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    if gameStatus != .running { return }
    
    var bodyA : SKPhysicsBody
    var bodyB : SKPhysicsBody
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      bodyA = contact.bodyA
      bodyB = contact.bodyB
    }else {
      bodyA = contact.bodyB
      bodyB = contact.bodyA
    }
    
    if (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == pipeCategory) ||
      (bodyA.categoryBitMask == birdCategory && bodyB.categoryBitMask == floorCategory) {
      gameOver()
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch gameStatus {
    case .idle:
      startGame()
    case .running:
      bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
    case .over:
      shuffle()
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    if gameStatus == .running {
      meters += 1
    }
    
    if gameStatus != .over {
      moveScene()
    }
  }
  
}
