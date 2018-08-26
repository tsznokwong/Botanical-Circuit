//
//  Extension.swift
//  Botanical Circuit
//
//  Created by Tsznok Wong on 29/7/2016.
//  Copyright © 2016 Tsznok Wong. All rights reserved.
//

import Foundation
import SpriteKit


public extension CGFloat {
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    public static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    func roundToPlaces(places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return round(self * divisor) / divisor
    }
}


func degreeToRadian(degree: CGFloat) -> CGFloat {
    return degree * CGFloat(M_PI / 180)
}

func radianToDegree(radian: CGFloat) -> CGFloat {
    return radian * CGFloat(180 / M_PI)
}

func distanceFromTwoPoints(a: CGPoint, _ b: CGPoint) -> CGFloat {
    return sqrt(square(a.x - b.x) + square(a.y - b.y))
}

func square(x: CGFloat) -> CGFloat {
    return x * x
}
func angleOfThreePoints(movePoint movePoint: CGPoint, refPoint: CGPoint, atPoint: CGPoint) -> CGFloat {
    let a = distanceFromTwoPoints(movePoint, atPoint)
    let b = distanceFromTwoPoints(refPoint, atPoint)
    let c = distanceFromTwoPoints(movePoint, refPoint)
    return acos((square(a) + square(b) - square(c)) / 2 / a / b)
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

prefix func - (rhs: CGPoint) -> CGPoint {
    return CGPoint(x: -rhs.x, y: -rhs.y)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return lhs + (-rhs)
}

func Color(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha / 100)
}

class Button : SKSpriteNode {
    init(imageNamed imagedName: String) {
        super.init(texture: SKTexture(imageNamed: imagedName), color: UIColor(), size: CGSize())
    }
    
    func fadeEffect() {
        self.runAction(SKAction.scaleTo(0.8, duration: 0.1))
        self.runAction(SKAction.fadeAlphaTo(0.8, duration: 0.1))
    }
    func unFadeEffect() {
        self.runAction(SKAction.scaleTo(1.0, duration: 0.1))
        self.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.1))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension XylemScene {
    override func didMoveToView(view: SKView) {
        ViewWidth = self.frame.width
        ViewHeight = self.frame.height
        self.backgroundColor = UIColor.greenColor()
        freeze = false
        
        //Background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: ViewWidth / 2, y: ViewHeight / 2)
        background.size = CGSize(width: ViewHeight / 850 * 1280,
                                 height: ViewHeight)
        background.zPosition = 1
        addChild(background)
        
        
        //Title
        Title.text = "「植」流電 Botanical Circuit"
        Title.horizontalAlignmentMode = .Center
        Title.fontColor = navyBlue
        
        Title.fontSize = ViewWidth * 0.05
        Title.position = CGPoint(x: ViewWidth / 2,
                                 y: ViewHeight - ViewWidth * 0.05 * 1.25 - 10)
        Title.zPosition = 4
        addChild(Title)
        
        //Alert
        addChild(Alert)
        
        //blur Background
        blurBackground.position = CGPoint(x: ViewWidth / 2, y: ViewHeight / 2)
        blurBackground.size = CGSize(width: ViewWidth, height: ViewHeight)
        blurBackground.zPosition = 15
        blurBackground.alpha = 0.6
        blurBackground.name = "blur"
        //addChild(blurBackground)
        
        //box
        box.position = CGPoint(x: ViewWidth / 2, y: ViewHeight / 2)
        box.zPosition = 16
        box.name = "box"
        
        //Restart Button
        restartButton.size = CGSize(width: ViewWidth * 0.05,
                                    height: ViewWidth * 0.05)
        restartButton.position = CGPoint(x: ViewWidth - restartButton.frame.width - 10,
                                         y: ViewHeight - restartButton.frame.height - 10)
        restartButton.zPosition = 10
        addChild(restartButton)
        
        //Info Button
        infoButton.size = CGSize(width: ViewWidth * 0.05,
                                 height: ViewWidth * 0.05)
        infoButton.position = CGPoint(x: infoButton.frame.width + 10,
                                      y: ViewHeight - infoButton.frame.height - 10)
        infoButton.zPosition = 10
        addChild(infoButton)
        
        //View Button
        viewButton.size = CGSize(width: ViewWidth * 0.05,
                                 height: ViewWidth * 0.05)
        viewButton.position = CGPoint(x: viewButton.frame.width + 10,
                                      y: ViewHeight / 2)
        viewButton.zPosition = 10
        addChild(viewButton)
        
        //Xylem
        Xylem.position = CGPoint(x: ViewWidth / 3,
                                 y: ViewHeight / 2)
        addChild(Xylem)
        
        //Xylem Low Layer
        XylemLowLayer.size = CGSize(width: ViewWidth * 0.6,
                                    height: ViewWidth * 0.6 / 1598 * 1589)
        XylemLowLayer.zPosition = 3
        Xylem.addChild(XylemLowLayer)
        
        //Xylem Top Layer
        let XylemTopLayer = SKSpriteNode(imageNamed: "XylemTopLayer")
        XylemTopLayer.position = CGPoint(x: XylemLowLayer.frame.width / 614.400024414062 * 90.667,
                                         y: -XylemLowLayer.frame.height / 610.940002441406 * 344)
        XylemTopLayer.size = CGSize(width: XylemLowLayer.frame.width / 1598 * 402,
                                    height: XylemLowLayer.frame.width / 1598 * 549)
        XylemTopLayer.zPosition = 8
        Xylem.addChild(XylemTopLayer)
        
        //Spawn H2O
        let spawn = SKAction.runBlock({
            () in
            self.createH2O()
        })
        let spawnDelay = SKAction.sequence([spawn, SKAction.waitForDuration(0.2)])
        self.runAction(SKAction.repeatActionForever(spawnDelay))
        
        //testTube
        testTube.position = CGPoint(x: ViewWidth / 5 * 3,
                                    y: ViewHeight / 2)
        testTube.size = CGSize(width: ViewWidth * 0.05,
                               height: ViewWidth * 0.05 / 405 * 1928)
        testTube.zPosition = 3
        addChild(testTube)
        
        //Panel
        panel.position = CGPoint(x: ViewWidth / 6 * 5,
                                 y: ViewHeight / 2)
        panel.size = CGSize(width: ViewWidth * 0.3,
                            height: ViewWidth * 0.3 / 543 * 785)
        panel.zPosition = 3
        addChild(panel)
        
        //Light Bulb
        let lightBulb = SKSpriteNode(imageNamed: "LightBulb")
        lightBulb.position = CGPoint(x: panel.position.x - panel.frame.width / 543 * 120,
                                     y: panel.position.y - panel.frame.height / 785 * 216)
        lightBulb.size = CGSize(width: panel.frame.width / 543 * 96,
                                height: panel.frame.width / 543 * 96)
        lightBulb.zPosition = 4
        addChild(lightBulb)
        
        //Knob
        knob.position = CGPoint(x: panel.position.x + panel.frame.width / 543 * 108,
                                y: panel.position.y - panel.frame.height / 785 * 216)
        knob.size = CGSize(width: panel.frame.width / 543 * 202,
                           height: panel.frame.width / 543 * 202)
        knob.zPosition = 4
        knob.zRotation = degreeToRadian(120)
        addChild(knob)
        
        //Voltmeter Reading
        volt = 0
        voltReading.text = "\(volt)"
        voltReading.horizontalAlignmentMode = .Right
        voltReading.fontColor = UIColor.blackColor()
        voltReading.fontSize = panel.frame.height / 785 * 120
        voltReading.position = CGPoint(x: panel.position.x + panel.frame.width / 543 * 120,
                                       y: panel.position.y + panel.frame.height / 785 * 220)
        voltReading.zPosition = 4
        addChild(voltReading)
        
        //ammeter Reading
        amme = 0
        ammeReading.text = "\(amme)"
        ammeReading.horizontalAlignmentMode = .Right
        ammeReading.fontColor = UIColor.blackColor()
        ammeReading.fontSize = panel.frame.height / 785 * 120
        ammeReading.position = CGPoint(x: panel.position.x + panel.frame.width / 543 * 120,
                                       y: panel.position.y - panel.frame.height / 785 * 10)
        ammeReading.zPosition = 4
        addChild(ammeReading)
        
        
        
        
    }
    
    func createH2O() {
        //water Molecule Property
        let waterMolecule = SKSpriteNode(imageNamed: "WaterMolecule")
        waterMolecule.name = "waterMolecule"
        waterMolecule.position = CGPoint(x: XylemLowLayer.frame.width / 1598 * 274 + CGFloat.random(min: -75, max: 75),
                                         y: -XylemLowLayer.frame.height / 1589 * 525)
        waterMolecule.size = CGSize(width: XylemLowLayer.frame.width * 0.04,
                                    height: XylemLowLayer.frame.width * 0.04 / 78 * 68)
        waterMolecule.zPosition = CGFloat.random(min: 4, max: 6)
        waterMolecule.zRotation = CGFloat.random(min: -CGFloat(M_PI), max: CGFloat(M_PI))
        Xylem.addChild(waterMolecule)
        
        //water Molecule Action
        let fadeIn = SKAction.fadeInWithDuration(0.2)
        let distance = XylemLowLayer.frame.height / 1589 * 1000
        let move = SKAction.moveBy(CGVector(dx: 0, dy: distance), duration: 3)
        let rotate = SKAction.rotateByAngle(CGFloat.random(min: -CGFloat(M_PI), max: CGFloat(M_PI)), duration: 3)
        let moveRotate = SKAction.group([move, rotate])
        let fadeOut = SKAction.fadeOutWithDuration(0.2)
        let remove = SKAction.removeFromParent()
        
        let moveAndRemove = SKAction.sequence([fadeIn, moveRotate, fadeOut, remove])
        waterMolecule.runAction(moveAndRemove)
    }
    
    func spawnPolymer() {
        //polymer Property
        let polymer = SKSpriteNode(imageNamed: "Polymer")
        polymer.size = CGSize(width: XylemLowLayer.frame.width * 0.24,
                              height: XylemLowLayer.frame.width * 0.24 / 507 * 1534)
        polymer.position = CGPoint(x: XylemLowLayer.frame.width / 1598 * 260,
                                   y: -XylemLowLayer.frame.height / 1589 * 525 - polymer.frame.height / 2)
        polymer.zPosition = 5
        polymer.name = "polymer"
        Xylem.addChild(polymer)
        
        //polymer Action
        var fadeIn = SKAction.fadeInWithDuration(0.7)
        let distance = XylemLowLayer.frame.height / 1589 * 1000
        let move = SKAction.moveBy(CGVector(dx: 0, dy: distance), duration: 3)
        let done = SKAction.runBlock({
            self.atTop = true
        })
        let moveUp = SKAction.group([fadeIn, move, done])
        let circle = UIBezierPath(roundedRect: CGRectMake(polymer.position.x - 5, polymer.position.y + distance, 10, 10), cornerRadius: 10)
        
        let followCircle = SKAction.followPath(circle.CGPath, asOffset: false, orientToPath: false, duration: 5.0)
        let action = SKAction.sequence([moveUp, SKAction.repeatActionForever(followCircle)])
        polymer.runAction(action)
        
        top = polymer.position.y + distance + polymer.frame.height / 2
        stdDistance = top + XylemLowLayer.frame.height / 1589 * 525 - polymer.frame.height / 10
        //electrons
        for iterator in 1 ... 10 {
            let electron = SKSpriteNode(imageNamed: "Electron")
            electron.name = "Electron"
            electron.size = CGSize(width: polymer.frame.width * 0.15,
                                   height: polymer.frame.width * 0.15)
            let distribution =  -polymer.frame.height * CGFloat(iterator) / 10
            electron.position = CGPoint(x: polymer.position.x,
                                        y: -XylemLowLayer.frame.height / 1589 * 525 + distribution)
            electron.zPosition = 7
            electron.hidden = true
            Xylem.addChild(electron)
            
            fadeIn = SKAction.fadeInWithDuration(0.2)
            
            let moveToTop = SKAction.moveToY(top, duration: Double((top - electron.position.y) / (stdDistance * amme * 0.5)))
            let fadeOut = SKAction.fadeOutWithDuration(0.2)
            let remove = SKAction.removeFromParent()
            electron.runAction(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
            
            if iterator == 10 {
                lastElectron = electron
                lastElectron.runAction(SKAction.sequence([fadeIn, moveToTop, fadeOut, remove]))
            }
        }
    }
    
    func setRotateAngle(location: CGPoint) {
        rotating = true
        firstTouchPoint = location
        refAngle = angleOfThreePoints(movePoint: firstTouchPoint,
                                      refPoint: CGPoint(x: knob.position.x, y: knob.position.y + 10),
                                      atPoint: knob.position)
        if firstTouchPoint.x > knob.position.x {
            refAngle = -refAngle
        }
        refAngle -= knob.zRotation
    }

}



