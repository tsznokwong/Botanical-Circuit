//
//  GameScene.swift
//  Botanical Circuit
//
//  Created by Tsznok Wong on 25/6/2016.
//  Copyright (c) 2016 Tsznok Wong. All rights reserved.
//

import SpriteKit

var ViewWidth = CGFloat()
var ViewHeight = CGFloat()
var moving = Bool()
var freeze = Bool()

let navyBlue = Color(red: 10, green: 7, blue: 46, alpha: 100)
let violet = Color(red: 174, green: 192, blue: 242, alpha: 80)

class XylemScene: SKScene {
    
    let Xylem = SKNode()
    
    let XylemLowLayer = SKSpriteNode(imageNamed: "Xylem")
    
    let testTube = SKSpriteNode(imageNamed: "testTube")
    var atTop = false
    var top = CGFloat()
    var stdDistance = CGFloat()
    var lastElectron = SKSpriteNode()
    var addSolution = false
    let oriResist = CGFloat(20000)
    let pedotResist = CGFloat(4000)
    
    let panel = SKSpriteNode(imageNamed: "Panel")
    let knob = SKSpriteNode(imageNamed: "Knob")
    var rotating = false
    var firstTouchPoint = CGPoint()
    var refAngle = CGFloat()
    
    let voltReading = SKLabelNode()
    var volt = CGFloat()
    let ammeReading = SKLabelNode()
    var amme = CGFloat()
    
    let Title = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    
    let restartButton = Button(imageNamed: "Restart")
    let infoButton = Button(imageNamed: "Info")
    let viewButton = Button(imageNamed: "View")
    var blurBackground = SKSpriteNode(color: UIColor.black,
                                      size: CGSize())
    let box = SKSpriteNode(color: violet,
                           size: CGSize(width: ViewWidth * 0.1, height: ViewHeight * 0.1))
    let Alert = SKNode()
    
        
    func addAlert() {
        freeze = true
        Alert.addChild(blurBackground)
        Alert.addChild(box)
        blurBackground.alpha = 0.6
        box.size = CGSize(width: ViewWidth * 0.05, height: ViewHeight * 0.05)
        let changeHeight = SKAction.resize(toHeight: ViewHeight * 0.7, duration: 0.2)
        let changeWidth = SKAction.resize(toWidth: ViewWidth * 0.7, duration: 0.2)
        box.run(SKAction.sequence([changeHeight, changeWidth]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedSprite = atPoint(location)
            if freeze {
                return
            }
            if touchedSprite.isKind(of: Button.self) {
                let button = touchedSprite as! Button
                button.fadeEffect()
            }
            if !restartButton.contains(location) {
                restartButton.unFadeEffect()
            }
            if !infoButton.contains(location) {
                infoButton.unFadeEffect()
            }
            if knob.contains(location) {
                if rotating {
                    var c = angleOfThreePoints(movePoint: location,
                                               refPoint: CGPoint(x: knob.position.x, y: knob.position.y + 10),
                                               atPoint: knob.position)
                    if location.x > knob.position.x {
                        c = -c
                    }
                    knob.zRotation = c - refAngle
                    if knob.zRotation > degreeToRadian(120) {
                        knob.zRotation = degreeToRadian(120)
                        setRotateAngle(location)
                    }
                    if knob.zRotation < degreeToRadian(-120) {
                        knob.zRotation = degreeToRadian(-120)
                        setRotateAngle(location)
                    }
                    
                    volt = 10 / (degreeToRadian(120) * 2) * (degreeToRadian(120) - knob.zRotation)
                    voltReading.text = "\(volt.roundToPlaces(1))"
                    amme = volt / (addSolution ? pedotResist : oriResist) * 1000
                    ammeReading.text = "\(amme.roundToPlaces(1))"
                    
                } else {
                    setRotateAngle(location)
                }
            } else {
                rotating = false
            }
            /*if moving {
                XylemTopLayer.position = location
                print(XylemTopLayer.position)
            }*/
        }
        
    
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedSprite = atPoint(location)
            
            if touchedSprite.name == "blur" {
                let fadeOut = SKAction.fadeOut(withDuration: 0.4)
                let changeWidth = SKAction.resize(toWidth: ViewWidth * 0.05, duration: 0.2)
                let changeHeight = SKAction.resize(toHeight: 0, duration: 0.2)
                let remove = SKAction.removeFromParent()
                let unfreeze = SKAction.run({
                    freeze = false
                })
                blurBackground.run(SKAction.sequence([fadeOut, remove, unfreeze]))
                box.run(SKAction.sequence([changeWidth, changeHeight, remove]))
                for node in Alert.children {
                    if node.name != "blur" && node.name != "box" {
                        node.removeFromParent()
                    }
                }
                return
            }
            if freeze {
                return
            }
            if testTube.contains(location) && addSolution == false {
                spawnPolymer()
                addSolution = true
                testTube.run(SKAction.fadeOut(withDuration: 1))
                if amme > 0 {
                    let change = (volt / pedotResist - volt / oriResist) * 1000 / 10
                    let addValue = SKAction.run({
                        self.amme += change
                        self.ammeReading.text = "\(self.amme.roundToPlaces(1))"
                    })
                    let delay = SKAction.wait(forDuration: 0.15)
                    run(SKAction.repeat(SKAction.sequence([addValue, delay]), count: 10))
                }
                
            }
            if touchedSprite.isKind(of: Button.self) {
                let button = touchedSprite as! Button
                button.fadeEffect()
            }
            
            if knob.contains(location) {
                setRotateAngle(location)
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moving = false
        rotating = false
        let delay = SKAction.fadeOut(withDuration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
    
        let spawn = SKAction.sequence([delay, fadeIn])
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedSprite = atPoint(location)
            if freeze {
                return
            }
            if touchedSprite.isKind(of: Button.self) {
                let button = touchedSprite as! Button
                button.unFadeEffect()
            }
            if restartButton.contains(location) {
                let transition = SKTransition.fade(withDuration: 0.2)
                let xylemScene = XylemScene(size: self.size)
                self.view?.presentScene(xylemScene, transition: transition)
            }
            if infoButton.contains(location) {
                let badge = SKSpriteNode(imageNamed: "SPC")
                badge.size = CGSize(width: ViewHeight * 0.17 / 725 * 592,
                                    height: ViewHeight * 0.17)
                badge.position = CGPoint(x: ViewWidth / 2,
                                         y: ViewHeight * 0.75)
                badge.zPosition = 17
                badge.alpha = 0
                badge.run(spawn)
                Alert.addChild(badge)
                
                let logo = SKSpriteNode(imageNamed: "49logo")
                logo.size = CGSize(width: ViewHeight * 0.08 / 141 * 884,
                                    height: ViewHeight * 0.08)
                logo.position = CGPoint(x: ViewWidth / 2,
                                         y: ViewHeight * 0.6)
                logo.zPosition = 17
                logo.alpha = 0
                logo.run(spawn)
                Alert.addChild(logo)
                
                let line = SKSpriteNode(color: navyBlue, size: CGSize(width: ViewWidth / 2, height: 2))
                line.position = CGPoint(x: ViewWidth / 2, y: ViewHeight * 0.55)
                line.zPosition = 17
                line.alpha = 0
                line.run(spawn)
                Alert.addChild(line)
                
                let chiName = SKLabelNode(text: "聖保羅書院")
                chiName.fontColor = navyBlue
                chiName.fontName = "Helvetica"
                chiName.horizontalAlignmentMode = .center
                chiName.fontSize = ViewWidth * 0.05
                chiName.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.45)
                chiName.zPosition = 17
                chiName.alpha = 0
                chiName.run(spawn)
                Alert.addChild(chiName)
                
                let engName = SKLabelNode(text: "St. Paul's College")
                engName.fontColor = navyBlue
                engName.fontName = "Helvetica"
                engName.horizontalAlignmentMode = .center
                engName.fontSize = ViewWidth * 0.04
                engName.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.37)
                engName.zPosition = 17
                engName.alpha = 0
                engName.run(spawn)
                Alert.addChild(engName)
                
                let phNumber = SKLabelNode(text: "PH01")
                phNumber.fontColor = navyBlue
                phNumber.fontName = "Helvetica"
                phNumber.horizontalAlignmentMode = .center
                phNumber.fontSize = ViewWidth * 0.03
                phNumber.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.3)
                phNumber.zPosition = 17
                phNumber.alpha = 0
                phNumber.run(spawn)
                Alert.addChild(phNumber)
                
                let copyright = SKLabelNode(text: "App by Joshua Wong")
                copyright.fontColor = navyBlue
                copyright.fontName = "Helvetica"
                copyright.horizontalAlignmentMode = .right
                copyright.fontSize = ViewWidth * 0.015
                copyright.position = CGPoint(x: ViewWidth * 0.82,
                                            y: ViewHeight * 0.17)
                copyright.zPosition = 17
                copyright.alpha = 0
                copyright.run(spawn)
                Alert.addChild(copyright)
                
                addAlert()
            }
            if viewButton.contains(location) {
                let model = SKSpriteNode(imageNamed: "Model" + (addSolution ? "" : "-nopedot"))
                model.size = CGSize(width: ViewHeight * 0.60 / 1526 * 1191,
                                    height: ViewHeight * 0.60)
                model.position = blurBackground.position + CGPoint(x: 0, y: -10)
                model.zPosition = 17
                model.alpha = 0
                model.run(spawn)
                Alert.addChild(model)
                
                let subtitle = SKLabelNode(text: "模型結構 Model structure")
                subtitle.fontColor = navyBlue
                subtitle.fontName = "Helvetica"
                subtitle.horizontalAlignmentMode = .center
                subtitle.fontSize = ViewWidth * 0.05
                subtitle.position = CGPoint(x: ViewWidth * 0.5,
                                            y: ViewHeight * 0.79)
                subtitle.zPosition = 17
                subtitle.alpha = 0
                subtitle.run(spawn)
                Alert.addChild(subtitle)
                
                addAlert()
            }

            if let node = Xylem.childNode(withName: "polymer") {
                let polymer = node as! SKSpriteNode
                if polymer.contains(location - Xylem.position) {
                    let chiTitle = SKLabelNode(text: "聚(3,4-乙烯二氧噻吩) 的特性")
                    chiTitle.fontColor = navyBlue
                    chiTitle.fontName = "Helvetica"
                    chiTitle.horizontalAlignmentMode = .center
                    chiTitle.fontSize = ViewWidth * 0.04
                    chiTitle.position = CGPoint(x: ViewWidth * 0.5,
                                                y: ViewHeight * 0.79)
                    chiTitle.zPosition = 17
                    chiTitle.alpha = 0
                    chiTitle.run(spawn)
                    Alert.addChild(chiTitle)
                    
                    let engTitle = SKLabelNode(text: "Properties of PEDOT (Poly(3,4-ethylenedioxythiophene))")
                    engTitle.fontColor = navyBlue
                    engTitle.fontName = "Helvetica"
                    engTitle.horizontalAlignmentMode = .center
                    engTitle.fontSize = ViewWidth * 0.02
                    engTitle.position = CGPoint(x: ViewWidth * 0.5,
                                                y: ViewHeight * 0.74)
                    engTitle.zPosition = 17
                    engTitle.alpha = 0
                    engTitle.run(spawn)
                    Alert.addChild(engTitle)
                    
                    let structure = SKSpriteNode(imageNamed: "PedotStructure")
                    structure.position = CGPoint(x: ViewWidth / 2,
                                                 y: ViewHeight * 0.45)
                    structure.size = CGSize(width: ViewHeight * 0.42 / 480 * 390,
                                            height: ViewHeight * 0.42)
                    structure.zPosition = 17
                    structure.alpha = 0
                    structure.run(spawn)
                    Alert.addChild(structure)
                    
                    let chiExplain = SKSpriteNode(imageNamed: "chiExplain")
                    chiExplain.position = CGPoint(x: ViewWidth * 0.27,
                                                  y: ViewHeight * 0.45)
                    chiExplain.size = CGSize(width: ViewHeight * 0.33 / 720 * 634,
                                            height: ViewHeight * 0.33)
                    chiExplain.zPosition = 17
                    chiExplain.alpha = 0
                    chiExplain.run(spawn)
                    Alert.addChild(chiExplain)
                    
                    let engExplain = SKSpriteNode(imageNamed: "engExplain")
                    engExplain.position = CGPoint(x: ViewWidth * 0.73,
                                                  y: ViewHeight * 0.45)
                    engExplain.size = CGSize(width: ViewHeight * 0.28 / 720 * 854,
                                            height: ViewHeight * 0.28)
                    engExplain.zPosition = 17
                    engExplain.alpha = 0
                    engExplain.run(spawn)
                    Alert.addChild(engExplain)
                    
                    addAlert()
                }
            }
        }
    }
    
    var lastIonizeWater = TimeInterval()
    var lastUpdateElectrons = TimeInterval()
    override func update(_ currentTime: TimeInterval) {
        let timeSinceLastIonizeWater = currentTime - lastIonizeWater
        if amme > 0 && timeSinceLastIonizeWater > (1 / amme > 1 ? Double(1 / amme) : 1) {
            lastIonizeWater = currentTime
            Xylem.enumerateChildNodes(withName: "waterMolecule", using: {
                (node, error) in
                let waterMolecule = node as! SKSpriteNode
                if CGFloat.random(min: 0, max: 1) < 0.1 {
                    // Spawn ions
                    let hydrogen = SKSpriteNode(imageNamed: "Hydrogen")
                    let hydroxide = SKSpriteNode(imageNamed: "Hydroxide")
                    hydrogen.position = waterMolecule.position
                    hydroxide.position = waterMolecule.position
                    hydrogen.zPosition = waterMolecule.zPosition
                    hydroxide.zPosition = waterMolecule.zPosition
                    hydrogen.size = CGSize(width: self.XylemLowLayer.frame.width * 0.04 / 78 * 34,
                                           height: self.XylemLowLayer.frame.width * 0.04 / 78 * 34)
                    hydroxide.size = CGSize(width: self.XylemLowLayer.frame.width * 0.04 / 78 * 61,
                                           height: self.XylemLowLayer.frame.width * 0.04 / 78 * 68)
                    self.Xylem.addChild(hydrogen)
                    self.Xylem.addChild(hydroxide)
                    waterMolecule.removeAllActions()
                    
                    //Actions
                    let fadeIn = SKAction.fadeIn(withDuration: 0.2)
                    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                    let remove = SKAction.removeFromParent()
                    waterMolecule.run(SKAction.sequence([fadeOut, remove]))
                    let waterMoleculeSpeed = self.XylemLowLayer.frame.height / 1589 * 1000 / 3
                    
                    //H ions Actions
                    let Hdistance = hydrogen.position.y + self.XylemLowLayer.frame.height / 1589 * 525
                    let Hmove = SKAction.move(by: CGVector(dx: 0, dy: -Hdistance),
                                                duration: Double(Hdistance / waterMoleculeSpeed))
                    let Hrotate = SKAction.rotate(byAngle: CGFloat.random(min: -CGFloat.pi, max: CGFloat.pi), duration: Double(Hdistance / waterMoleculeSpeed))
                    var moveRotate = SKAction.group([Hmove, Hrotate])
                    var moveAndRemove = SKAction.sequence([fadeIn, moveRotate, fadeOut, remove])
                    hydrogen.run(moveAndRemove)
                    //OH ions Actions
                    let OHdistance = self.XylemLowLayer.frame.height / 1589 * 475 - hydrogen.position.y
                    let OHmove = SKAction.move(by: CGVector(dx: 0, dy: OHdistance),
                                                 duration: Double(OHdistance / waterMoleculeSpeed))
                    let OHrotate = SKAction.rotate(byAngle: CGFloat.random(min: -CGFloat.pi, max: CGFloat.pi), duration: Double(OHdistance / waterMoleculeSpeed))
                    moveRotate = SKAction.group([OHmove, OHrotate])
                    moveAndRemove = SKAction.sequence([fadeIn, moveRotate, fadeOut, remove])
                    hydroxide.run(moveAndRemove)
                }
            })
        }
        let timeSinceUpdateElectrons = currentTime - lastUpdateElectrons
        if timeSinceUpdateElectrons > 0.1 {
            lastUpdateElectrons = currentTime
            if amme > 0 && addSolution {
                let polymer = Xylem.childNode(withName: "polymer")!
                if lastElectron.position.y + XylemLowLayer.frame.height / 1589 * 585 > polymer.frame.height / 10 {
                    let electron = SKSpriteNode(imageNamed: "Electron")
                    electron.name = "Electron"
                    electron.size = CGSize(width: polymer.frame.width * 0.15,
                                           height: polymer.frame.width * 0.15)
                    electron.position = CGPoint(x: polymer.position.x,
                                                y: -XylemLowLayer.frame.height / 1589 * 585)
                    electron.zPosition = 7
                    electron.isHidden = true
                    Xylem.addChild(electron)
                    
                    let fadeIn = SKAction.fadeIn(withDuration: 0.2)
                    let moveToTop = SKAction.moveTo(y: top, duration: Double((top - electron.position.y) / (stdDistance * amme * 0.5)))
                    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                    let remove = SKAction.removeFromParent()
                    electron.run(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
                    
                    lastElectron = electron
                    lastElectron.run(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
                
                }
                Xylem.enumerateChildNodes(withName: "Electron", using: {
                    (node, error) in
                    let electron = node as! SKSpriteNode
                    electron.isHidden = false
                    
                    electron.removeAllActions()
                    let moveToTop = SKAction.moveTo(y: self.top, duration: Double((self.top - electron.position.y) / (self.stdDistance * self.amme * 0.5)))
                    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                    let remove = SKAction.removeFromParent()
                    electron.run(SKAction.sequence([
                        moveToTop, fadeOut, remove]))
                })
            } else if amme < 0 {
                Xylem.enumerateChildNodes(withName: "Electron", using: {
                    (node, error) in
                    let electron = node as! SKSpriteNode
                    electron.isHidden = true
                })
            }
        }
    }
    
   
}
