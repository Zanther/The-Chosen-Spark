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
    var instructionLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    var score = 0 {
        didSet {
            instructionLabel.text = "Rescue the Autobot hidden among the disguised Decepticons!"
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
    var xOffset = -180
    var yOffset = 0
    var gridX = 9
    var gridY = 4
    
    override func sceneDidLoad() {
        
        let background = SKSpriteNode(imageNamed: "background-metal")
        background.name = "background"
        background.zPosition = -1
        background.setScale(2)
        addChild(background)
        
        let bgMusic = SKAudioNode(fileNamed: "bg_chosenSpark")
        background.addChild(bgMusic)
        
        scoreLabel.fontSize = 12
//        scoreLabel.position = CGPoint(x:-350, y:200)
        scoreLabel.position = CGPoint(x:-140, y:275)
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        
        levelLabel.fontSize = 12
        levelLabel.position = CGPoint(x:-110, y:295)
        levelLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .left
        
        timeLabel.fontSize = 42
        timeLabel.position = CGPoint(x:120, y:275)
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.zPosition = 1
        
        instructionLabel.fontSize = 12
        instructionLabel.position = CGPoint(x:-140, y:230)
        instructionLabel.zPosition = 1
        instructionLabel.horizontalAlignmentMode = .left
        instructionLabel.numberOfLines = 0
        instructionLabel.lineBreakMode = .byWordWrapping
        instructionLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width/1.5
        background.addChild(instructionLabel)
        background.addChild(scoreLabel)
        background.addChild(levelLabel)
        background.addChild(timeLabel)
        
        print("Max Width", UIScreen.main.bounds.maxX, instructionLabel.text as Any)

        createGrid()
        createLevel(withDelay: 2.0)

        score = 0
    }
    
    func createSKLabelWithMultipleLines (with textString: String, with labelName: String) -> SKLabelNode {
        guard let label = self.childNode(withName: labelName) as? SKLabelNode else { return SKLabelNode(fontNamed: "Menlo-Bold")}
        label.fontName = "Menlo-Bold"
        label.text = textString
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = UIScreen.main.bounds.maxX
//        print("Max Width", UIScreen.main.bounds.maxX, label.text)
        
        return label
    }
    
    func createGrid() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            xOffset = -200 /*-Int(UIScreen.main.bounds.width / 7)*/
            yOffset = -575 // -Int(UIScreen.main.bounds.height / 1.75)
            print("iPhone", "xoffset", xOffset, "yoffset", yOffset)
        } else {
            xOffset = -323
            yOffset = -220
            gridX = 7
            gridY = 11
        }
        
        for row in 0 ..< gridX {
            for col in 0 ..< gridY {
                let item = SKSpriteNode(imageNamed: "autobot_off")
                item.position = CGPoint(x: xOffset + (col * 130), y: yOffset + (row * 120))
//                item.position = CGPoint(x: xOffset + (col * 64), y: yOffset + (row * 60))
                item.setScale(1.25)
                addChild(item)
            }
        }
    }
    
    func createLevel(withDelay: Double) {
        if itemsToShow >= 84 {
            print("reached the end, reverse and add a +")
        } else if itemsToShow >= 4 {
            itemsToShow = 36 //itemsToShow + level
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
            let remainingTime = Int(ceil(30 - timePassed))
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
                restartLabel.text = "Game will Restart in: \(restartCountdown)"
                restartLabel.fontSize = 15
                restartLabel.position = CGPoint(x: gameOver.anchorPoint.x, y: gameOver.anchorPoint.y + 100)
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
