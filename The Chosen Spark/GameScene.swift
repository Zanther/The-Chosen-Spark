//
//  GameScene.swift
//  The Chosen Spark
//
//  Created by Steven Lattenhauer 2nd on 9/30/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var level = 1
    var itemsToShow = 4
    var wrongAnswers = 0
    let scoreLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let levelLabel = SKLabelNode(fontNamed: "Menlo-Bold")
//    var instructionLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var instructionLabel = SKLabelNode()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            levelLabel.text = "Level: \(level)"
        }
    }
    // "Rescue the Autobot hidden among the disguised Decepticons!"
    
    var startTime = 0.0
    var restartTime = 0.0
    var timeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var isGameRunning = true
    var restartLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    
    override func sceneDidLoad() {
        let scoreLabelPosition = isDeviceAniPhone() ? CGPoint(x:-140, y:275) : CGPoint(x:-100, y:110)
        let levelLabelPosition = isDeviceAniPhone() ? CGPoint(x:-110, y:295) : CGPoint(x:-145, y:110)
        let timeLabelPosition = isDeviceAniPhone() ? CGPoint(x:100, y:275) : CGPoint(x:155, y:110)
        let instructionLabelPosition = isDeviceAniPhone() ? CGPoint(x:-140, y:260) : CGPoint(x:-175, y:105)
        
        let background = SKSpriteNode(imageNamed: "background-metal")
        background.name = "background"
        background.zPosition = -1
        background.setScale(2)
        addChild(background)
        
        let bgMusic = SKAudioNode(fileNamed: "bg_chosenSpark")
        background.addChild(bgMusic)
        
        scoreLabel.fontSize = 12
        scoreLabel.position = scoreLabelPosition
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        
        levelLabel.fontSize = 12
        levelLabel.position = levelLabelPosition
        levelLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        
        timeLabel.fontSize = isDeviceAniPhone() ? 42 : 20
        timeLabel.position = timeLabelPosition
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.zPosition = 1
        
        instructionLabel = SKLabelMultiLineNode(text: "Rescue the Autobot hidden among the disguised Decepticons!",
                                                fontName: "Menlo-Bold",
                                                fontSize: isDeviceAniPhone() ? 12 : 10,
                                                hAlignment: .left,
                                                vAlignment: .top,
                                                labelWidth: UIScreen.main.bounds.width/1.5,
                                                position: instructionLabelPosition,
                                                zPosition: 1)
        
        background.addChild(instructionLabel)
        background.addChild(scoreLabel)
        background.addChild(levelLabel)
        background.addChild(timeLabel)
        
        print("Max Width", UIScreen.main.bounds.width/1.5, instructionLabel.text as Any)

        createGrid()
        createLevel(withDelay: 2.0)

        score = 0
    }
    
    func isDeviceAniPhone() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }
        return false
    }
    
    func createMultiLineLabelNode (from node: SKLabelNode,
                                   with textString: String,
                                   nodeWidth: CGFloat,
                                   fontName: String,
                                   fontSize: CGFloat,
                                   hAlignment: SKLabelHorizontalAlignmentMode,
                                   vAlignment: SKLabelVerticalAlignmentMode,
                                   position: CGPoint,
                                   zPosition: CGFloat) -> SKLabelNode {
        
        let multiLineLabelNode = node
        
        multiLineLabelNode.fontName = fontName
        multiLineLabelNode.text = textString
        multiLineLabelNode.lineBreakMode = .byWordWrapping
        multiLineLabelNode.numberOfLines = 0
        multiLineLabelNode.preferredMaxLayoutWidth = nodeWidth
        multiLineLabelNode.fontSize = fontSize

        return node
    }
    
    func createGrid() {
        let xOffset = isDeviceAniPhone() ? -200 : -323
        let yOffset = isDeviceAniPhone() ? -575 : -220
        let gridX = isDeviceAniPhone() ? 9 : 7
        let gridY = isDeviceAniPhone() ? 4 : 11
        
        if isDeviceAniPhone() {
            print("iPhone", "xoffset", xOffset, "yoffset", yOffset)
        } else {
            print("iPad", "xoffset", xOffset, "yoffset", yOffset)
        }
        
        for row in 0 ..< gridX {
            for col in 0 ..< gridY {
                let iPhonePosition = CGPoint(x: xOffset + (col * 130), y: yOffset + (row * 120))
                let iPadPosition = CGPoint(x: xOffset + (col * 64), y: yOffset + (row * 60))
                let item = SKSpriteNode(imageNamed: "autobot_off")
                let scale = isDeviceAniPhone() ? 1.25 : 1.00
                item.position = isDeviceAniPhone() ? iPhonePosition : iPadPosition
                item.setScale(scale)
                addChild(item)
            }
        }
    }
    
    func createLevel(withDelay: Double) {
        if itemsToShow >= 84 {
            print("reached the end, reverse and add a +")
        } else if itemsToShow >= 4 {
            itemsToShow = itemsToShow + level
        }
        wrongAnswers = 0
        
        let items = children.filter { $0.name != "background" }
        
        let shuffled = (items as NSArray).shuffled() as! [SKSpriteNode]
        
        for item in shuffled {
            item.alpha = 0
        }
        
        shuffled[0].name = "correct"
        shuffled[0].alpha = 1
        
        let lights = [SKTexture(imageNamed: "autobot_on"), SKTexture(imageNamed: "autobot_off")]
        let change = SKAction.animate(with: lights, timePerFrame: 0.3)
        var delay = 0.5
        
        
        for i in 1 ..< itemsToShow {
            let item = shuffled[i]
            item.name = "wrong"
            item.alpha = 1
            
            let refresh = SKAction.playSoundFileNamed("refreshEnemy.m4a", waitForCompletion: false)
            let ourPause = SKAction.wait(forDuration: delay)
            let sequence = SKAction.sequence([ourPause, refresh, change])
            item.run(sequence)
            
            delay += 0.1
        }
        isUserInteractionEnabled = true
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard isGameRunning else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        guard let tapped = tappedNodes.first else { return }
        
        if tapped.name == "correct" {
            correctAnswer(node: tapped)
        } else if tapped.name == "wrong" {
            wrongAnswer(node: tapped, tappedNodes: tappedNodes)
        }
    }
    
    func wrongAnswer(node: SKNode, tappedNodes: [SKNode]) {
        
        run(SKAction.playSoundFileNamed("wrongSound.m4a", waitForCompletion: false))
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        node.run(fadeOut)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let reveal = SKAction.setTexture(SKTexture(imageNamed: "decepticon"))
        wrongAnswers = wrongAnswers + 1
        
        print("tapped nodes count", itemsToShow, wrongAnswers)
        score = score - 5
        if score < 0 {
            score = 0
        }
        if let wrong = SKEmitterNode(fileNamed: "wrongChoice") {
            wrong.position = node.position
            wrong.zPosition = 5
            addChild(wrong)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                node.run(reveal)
                node.run(fadeIn)
                wrong.removeFromParent()
                
                if self.wrongAnswers == self.itemsToShow - 1 {
                    print("You failed to rescue the autobot!, demoted!")
                    self.level -= 1
                    if self.level == 0 {
                        self.level = 1
                        print("GAME OVER")
                        self.createLevel(withDelay: 1)
                    }
                }
            }
        }
        print("Wrong")
    }
    
    func correctAnswer(node: SKNode) {
        startTime = 0
        
        run(SKAction.playSoundFileNamed("correctSound.m4a", waitForCompletion: false))
        
        for child in children {
            guard child.name == "wrong" else { continue }
        }
        score += 50
        print("Correct Items to Show, Wrong Answers Selected", itemsToShow, wrongAnswers, score, level)
        print("New score calcuation", (itemsToShow - wrongAnswers) * 5 * level)
        
        if let correct = SKEmitterNode(fileNamed: "correctChoice") {
            correct.position = node.position
            correct.zPosition = -1
            addChild(correct)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                correct.removeFromParent()
                self.level = self.level + 1
                self.createLevel(withDelay: 0.5)
            }
        }
        
        let scaleUp = SKAction.scale(to: 3, duration: 0.25)
        let scaleDown = SKAction.scale(to: 1.25, duration: 0.25)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        node.run(sequence)
        
        isUserInteractionEnabled = false
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if isGameRunning {
            if startTime == 0 {
                startTime = currentTime
            }
            
            if restartTime == 0 {
                restartTime = currentTime
            }
            
            let timePassed = currentTime - startTime
            let remainingTime = Int(ceil(10 - timePassed))
            timeLabel.text = "\(remainingTime)"
            timeLabel.alpha = 1
            
            if remainingTime <= 0 {
                
                let restartTimePassed = currentTime - restartTime
                let restartCountdown = Int(ceil(20 - restartTimePassed))
                isGameRunning = false
        
                let gameOver = SKSpriteNode(imageNamed: "gameOver-1")
                run(SKAction.playSoundFileNamed("gameOverLow", waitForCompletion: true))
                gameOver.zPosition = 100
                addChild(gameOver)

                restartLabel.zPosition = 15
                restartLabel.text = "The game will restart in 20 Seconds"
                restartLabel.fontSize = 15
                restartLabel.position = CGPoint(x: gameOver.anchorPoint.x, y: gameOver.anchorPoint.y - 100)
                gameOver.addChild(restartLabel)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 18) {
                    if let scene = GameScene(fileNamed: "GameScene") {
                        scene.scaleMode = .aspectFill
                        self.view?.presentScene(scene)
                    }
                }
            }
        } else {
            timeLabel.alpha = 0
        }
    }
}
