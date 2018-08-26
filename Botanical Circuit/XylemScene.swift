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
    var blurBackground = SKSpriteNode(color: UIColor.blackColor(),
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
        let changeHeight = SKAction.resizeToHeight(ViewHeight * 0.7, duration: 0.2)
        let changeWidth = SKAction.resizeToWidth(ViewWidth * 0.7, duration: 0.2)
        box.runAction(SKAction.sequence([changeHeight, changeWidth]))
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedSprite = nodeAtPoint(location)
            if freeze {
                return
            }
            if touchedSprite.isKindOfClass(Button) {
                let button = touchedSprite as! Button
                button.fadeEffect()
            }
            if !restartButton.containsPoint(location) {
                restartButton.unFadeEffect()
            }
            if !infoButton.containsPoint(location) {
                infoButton.unFadeEffect()
            }
            if knob.containsPoint(location) {
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedSprite = nodeAtPoint(location)
            
            if touchedSprite.name == "blur" {
                let fadeOut = SKAction.fadeOutWithDuration(0.4)
                let changeWidth = SKAction.resizeToWidth(ViewWidth * 0.05, duration: 0.2)
                let changeHeight = SKAction.resizeToHeight(0, duration: 0.2)
                let remove = SKAction.removeFromParent()
                let unfreeze = SKAction.runBlock({
                    freeze = false
                })
                blurBackground.runAction(SKAction.sequence([fadeOut, remove, unfreeze]))
                box.runAction(SKAction.sequence([changeWidth, changeHeight, remove]))
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
            if testTube.containsPoint(location) && addSolution == false {
                spawnPolymer()
                addSolution = true
                testTube.runAction(SKAction.fadeOutWithDuration(1))
                if amme > 0 {
                    let change = (volt / pedotResist - volt / oriResist) * 1000 / 10
                    let addValue = SKAction.runBlock({
                        self.amme += change
                        self.ammeReading.text = "\(self.amme.roundToPlaces(1))"
                    })
                    let delay = SKAction.waitForDuration(0.15)
                    runAction(SKAction.repeatAction(SKAction.sequence([addValue, delay]), count: 10))
                }
                
            }
            if touchedSprite.isKindOfClass(Button) {
                let button = touchedSprite as! Button
                button.fadeEffect()
            }
            
            if knob.containsPoint(location) {
                setRotateAngle(location)
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        moving = false
        rotating = false
        let delay = SKAction.fadeOutWithDuration(0.3)
        let fadeIn = SKAction.fadeInWithDuration(0.1)
    
        let spawn = SKAction.sequence([delay, fadeIn])
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedSprite = nodeAtPoint(location)
            if freeze {
                return
            }
            if touchedSprite.isKindOfClass(Button) {
                let button = touchedSprite as! Button
                button.unFadeEffect()
            }
            if restartButton.containsPoint(location) {
                let transition = SKTransition.fadeWithDuration(0.2)
                let xylemScene = XylemScene(size: self.size)
                self.view?.presentScene(xylemScene, transition: transition)
            }
            if infoButton.containsPoint(location) {
                let badge = SKSpriteNode(imageNamed: "SPC")
                badge.size = CGSize(width: ViewHeight * 0.17 / 725 * 592,
                                    height: ViewHeight * 0.17)
                badge.position = CGPoint(x: ViewWidth / 2,
                                         y: ViewHeight * 0.75)
                badge.zPosition = 17
                badge.alpha = 0
                badge.runAction(spawn)
                Alert.addChild(badge)
                
                let logo = SKSpriteNode(imageNamed: "49logo")
                logo.size = CGSize(width: ViewHeight * 0.08 / 141 * 884,
                                    height: ViewHeight * 0.08)
                logo.position = CGPoint(x: ViewWidth / 2,
                                         y: ViewHeight * 0.6)
                logo.zPosition = 17
                logo.alpha = 0
                logo.runAction(spawn)
                Alert.addChild(logo)
                
                let line = SKSpriteNode(color: navyBlue, size: CGSize(width: ViewWidth / 2, height: 2))
                line.position = CGPoint(x: ViewWidth / 2, y: ViewHeight * 0.55)
                line.zPosition = 17
                line.alpha = 0
                line.runAction(spawn)
                Alert.addChild(line)
                
                let chiName = SKLabelNode(text: "聖保羅書院")
                chiName.fontColor = navyBlue
                chiName.fontName = "Helvetica"
                chiName.horizontalAlignmentMode = .Center
                chiName.fontSize = ViewWidth * 0.05
                chiName.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.45)
                chiName.zPosition = 17
                chiName.alpha = 0
                chiName.runAction(spawn)
                Alert.addChild(chiName)
                
                let engName = SKLabelNode(text: "St. Paul's College")
                engName.fontColor = navyBlue
                engName.fontName = "Helvetica"
                engName.horizontalAlignmentMode = .Center
                engName.fontSize = ViewWidth * 0.04
                engName.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.37)
                engName.zPosition = 17
                engName.alpha = 0
                engName.runAction(spawn)
                Alert.addChild(engName)
                
                let phNumber = SKLabelNode(text: "PH01")
                phNumber.fontColor = navyBlue
                phNumber.fontName = "Helvetica"
                phNumber.horizontalAlignmentMode = .Center
                phNumber.fontSize = ViewWidth * 0.03
                phNumber.position = CGPoint(x: ViewWidth * 0.5,
                                           y: ViewHeight * 0.3)
                phNumber.zPosition = 17
                phNumber.alpha = 0
                phNumber.runAction(spawn)
                Alert.addChild(phNumber)
                
                let copyright = SKLabelNode(text: "App by Joshua Wong")
                copyright.fontColor = navyBlue
                copyright.fontName = "Helvetica"
                copyright.horizontalAlignmentMode = .Right
                copyright.fontSize = ViewWidth * 0.015
                copyright.position = CGPoint(x: ViewWidth * 0.82,
                                            y: ViewHeight * 0.17)
                copyright.zPosition = 17
                copyright.alpha = 0
                copyright.runAction(spawn)
                Alert.addChild(copyright)
                
                addAlert()
            }
            if viewButton.containsPoint(location) {
                let model = SKSpriteNode(imageNamed: "Model" + (addSolution ? "" : "-nopedot"))
                model.size = CGSize(width: ViewHeight * 0.60 / 1526 * 1191,
                                    height: ViewHeight * 0.60)
                model.position = blurBackground.position + CGPoint(x: 0, y: -10)
                model.zPosition = 17
                model.alpha = 0
                model.runAction(spawn)
                Alert.addChild(model)
                
                let subtitle = SKLabelNode(text: "模型結構 Model structure")
                subtitle.fontColor = navyBlue
                subtitle.fontName = "Helvetica"
                subtitle.horizontalAlignmentMode = .Center
                subtitle.fontSize = ViewWidth * 0.05
                subtitle.position = CGPoint(x: ViewWidth * 0.5,
                                            y: ViewHeight * 0.79)
                subtitle.zPosition = 17
                subtitle.alpha = 0
                subtitle.runAction(spawn)
                Alert.addChild(subtitle)
                
                addAlert()
            }

            if let node = Xylem.childNodeWithName("polymer") {
                let polymer = node as! SKSpriteNode
                if polymer.containsPoint(location - Xylem.position) {
                    let chiTitle = SKLabelNode(text: "聚(3,4-乙烯二氧噻吩) 的特性")
                    chiTitle.fontColor = navyBlue
                    chiTitle.fontName = "Helvetica"
                    chiTitle.horizontalAlignmentMode = .Center
                    chiTitle.fontSize = ViewWidth * 0.04
                    chiTitle.position = CGPoint(x: ViewWidth * 0.5,
                                                y: ViewHeight * 0.79)
                    chiTitle.zPosition = 17
                    chiTitle.alpha = 0
                    chiTitle.runAction(spawn)
                    Alert.addChild(chiTitle)
                    
                    let engTitle = SKLabelNode(text: "Properties of PEDOT (Poly(3,4-ethylenedioxythiophene))")
                    engTitle.fontColor = navyBlue
                    engTitle.fontName = "Helvetica"
                    engTitle.horizontalAlignmentMode = .Center
                    engTitle.fontSize = ViewWidth * 0.02
                    engTitle.position = CGPoint(x: ViewWidth * 0.5,
                                                y: ViewHeight * 0.74)
                    engTitle.zPosition = 17
                    engTitle.alpha = 0
                    engTitle.runAction(spawn)
                    Alert.addChild(engTitle)
                    
                    let structure = SKSpriteNode(imageNamed: "PedotStructure")
                    structure.position = CGPoint(x: ViewWidth / 2,
                                                 y: ViewHeight * 0.45)
                    structure.size = CGSize(width: ViewHeight * 0.42 / 480 * 390,
                                            height: ViewHeight * 0.42)
                    structure.zPosition = 17
                    structure.alpha = 0
                    structure.runAction(spawn)
                    Alert.addChild(structure)
                    
                    let chiExplain = SKSpriteNode(imageNamed: "chiExplain")
                    chiExplain.position = CGPoint(x: ViewWidth * 0.27,
                                                  y: ViewHeight * 0.45)
                    chiExplain.size = CGSize(width: ViewHeight * 0.33 / 720 * 634,
                                            height: ViewHeight * 0.33)
                    chiExplain.zPosition = 17
                    chiExplain.alpha = 0
                    chiExplain.runAction(spawn)
                    Alert.addChild(chiExplain)
                    
                    let engExplain = SKSpriteNode(imageNamed: "engExplain")
                    engExplain.position = CGPoint(x: ViewWidth * 0.73,
                                                  y: ViewHeight * 0.45)
                    engExplain.size = CGSize(width: ViewHeight * 0.28 / 720 * 854,
                                            height: ViewHeight * 0.28)
                    engExplain.zPosition = 17
                    engExplain.alpha = 0
                    engExplain.runAction(spawn)
                    Alert.addChild(engExplain)
                    
                    addAlert()
                }
            }
        }
    }
    
    var lastIonizeWater = NSTimeInterval()
    var lastUpdateElectrons = NSTimeInterval()
    override func update(currentTime: CFTimeInterval) {
        let timeSinceLastIonizeWater = currentTime - lastIonizeWater
        if amme > 0 && timeSinceLastIonizeWater > (1 / amme > 1 ? Double(1 / amme) : 1) {
            lastIonizeWater = currentTime
            Xylem.enumerateChildNodesWithName("waterMolecule", usingBlock: {
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
                    let fadeIn = SKAction.fadeInWithDuration(0.2)
                    let fadeOut = SKAction.fadeOutWithDuration(0.2)
                    let remove = SKAction.removeFromParent()
                    waterMolecule.runAction(SKAction.sequence([fadeOut, remove]))
                    let waterMoleculeSpeed = self.XylemLowLayer.frame.height / 1589 * 1000 / 3
                    
                    //H ions Actions
                    let Hdistance = hydrogen.position.y + self.XylemLowLayer.frame.height / 1589 * 525
                    let Hmove = SKAction.moveBy(CGVector(dx: 0, dy: -Hdistance),
                                                duration: Double(Hdistance / waterMoleculeSpeed))
                    let Hrotate = SKAction.rotateByAngle(CGFloat.random(min: -CGFloat(M_PI), max: CGFloat(M_PI)), duration: Double(Hdistance / waterMoleculeSpeed))
                    var moveRotate = SKAction.group([Hmove, Hrotate])
                    var moveAndRemove = SKAction.sequence([fadeIn, moveRotate, fadeOut, remove])
                    hydrogen.runAction(moveAndRemove)
                    //OH ions Actions
                    let OHdistance = self.XylemLowLayer.frame.height / 1589 * 475 - hydrogen.position.y
                    let OHmove = SKAction.moveBy(CGVector(dx: 0, dy: OHdistance),
                                                 duration: Double(OHdistance / waterMoleculeSpeed))
                    let OHrotate = SKAction.rotateByAngle(CGFloat.random(min: -CGFloat(M_PI), max: CGFloat(M_PI)), duration: Double(OHdistance / waterMoleculeSpeed))
                    moveRotate = SKAction.group([OHmove, OHrotate])
                    moveAndRemove = SKAction.sequence([fadeIn, moveRotate, fadeOut, remove])
                    hydroxide.runAction(moveAndRemove)
                }
            })
        }
        let timeSinceUpdateElectrons = currentTime - lastUpdateElectrons
        if timeSinceUpdateElectrons > 0.1 {
            lastUpdateElectrons = currentTime
            if amme > 0 && addSolution {
                let polymer = Xylem.childNodeWithName("polymer")!
                if lastElectron.position.y + XylemLowLayer.frame.height / 1589 * 585 > polymer.frame.height / 10 {
                    let electron = SKSpriteNode(imageNamed: "Electron")
                    electron.name = "Electron"
                    electron.size = CGSize(width: polymer.frame.width * 0.15,
                                           height: polymer.frame.width * 0.15)
                    electron.position = CGPoint(x: polymer.position.x,
                                                y: -XylemLowLayer.frame.height / 1589 * 585)
                    electron.zPosition = 7
                    electron.hidden = true
                    Xylem.addChild(electron)
                    
                    let fadeIn = SKAction.fadeInWithDuration(0.2)
                    let moveToTop = SKAction.moveToY(top, duration: Double((top - electron.position.y) / (stdDistance * amme * 0.5)))
                    let fadeOut = SKAction.fadeOutWithDuration(0.2)
                    let remove = SKAction.removeFromParent()
                    electron.runAction(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
                    
                    lastElectron = electron
                    lastElectron.runAction(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
                
                }
                Xylem.enumerateChildNodesWithName("Electron", usingBlock: {
                    (node, error) in
                    let electron = node as! SKSpriteNode
                    electron.hidden = false
                    
                    electron.removeAllActions()
                    let moveToTop = SKAction.moveToY(self.top, duration: Double((self.top - electron.position.y) / (self.stdDistance * self.amme * 0.5)))
                    let fadeOut = SKAction.fadeOutWithDuration(0.2)
                    let remove = SKAction.removeFromParent()
                    electron.runAction(SKAction.sequence([
                        moveToTop, fadeOut, remove]))
                })
            } else if amme < 0 {
                Xylem.enumerateChildNodesWithName("Electron", usingBlock: {
                    (node, error) in
                    let electron = node as! SKSpriteNode
                    electron.hidden = true
                })
            }
        }
    }
    
   
}
