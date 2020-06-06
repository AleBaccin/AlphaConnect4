//
//  GameView.swift
//  Connect4
//
//  Created by Alessandro Baccin on 27/03/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit
import Alpha0Connect4

class GameView : UIView {
    var discBehavior : DiscBehavior? = nil
    weak var delegate : GameDataSource?
    //MARK: - Graphic properties
    var discViews = [EllipseView]() //Easy for numbering the discs
    
    func hasBoundaries() -> Bool{
        guard discBehavior!.collider.boundary(withIdentifier: "boardBottom" as NSCopying) != nil else {
            return false
        }
        for c in 1..<7 {
            guard discBehavior!.collider.boundary(withIdentifier: "column\(c)" as NSCopying) != nil else {
                return false
            }
        }
        
        return true
    }
    
    //MARK: - Actual grid adder and removes
    func removeBoundaries() {
        discBehavior!.collider.removeBoundary(withIdentifier: "boardBottom" as NSCopying)
        for c in 1..<7 {
            discBehavior!.collider.removeBoundary(withIdentifier: "column\(c)" as NSCopying)
        }
    }
    
    func addBoundaries(bottom: CGPoint) {
        discBehavior!.collider.addBoundary(withIdentifier: "boardBottom" as NSCopying,
                                           from: CGPoint.init(x: 0, y: bottom.y),
                                           to: CGPoint.init(x: self.bounds.width, y: bottom.y))
        for c in 1..<7 {
            discBehavior!.collider.addBoundary(withIdentifier: "column\(c)" as NSCopying,
                                      from: CGPoint.init(x: CGFloat(c) * self.bounds.width / 7, y: 0),
                                      to: CGPoint.init(x: CGFloat(c) * self.bounds.width / 7, y: self.bounds.height))
        }
    }
    
    private var discSize : CGSize? { get{
            return CGSize.init(width: self.bounds.width/7 - 1, height: self.bounds.width/7 - 1)
        }
    }
    private var widthSectors : [CGFloat]? { get {
        let sectorSize = self.bounds.width/7
            var sectors = [CGFloat]()
            for at in 0..<8 {
                sectors.append(sectorSize*CGFloat(at))
            }
            return sectors
        }
    }
    private var heightSectors : [CGFloat]? { get {
        let sectorSize = self.bounds.height/6
            var sectors = [CGFloat]()
            for at in 1..<7 {
                sectors.append(sectorSize*CGFloat(at))
                print(sectorSize*CGFloat(at))
            }
            return sectors
        }
    }

    func resolveSector(point: CGFloat) -> Int? {
        //Resolving the column given the point where user touches
        
        for sector in 0..<widthSectors!.count - 1 {
            //print("At: \(point), sec \(widthSectors![sector].rounded()), sec + 1 \(widthSectors![sector + 1].rounded())")
            if point > widthSectors![sector].rounded() && point < widthSectors![sector+1] &&
                !(point < widthSectors![sector] && point > widthSectors![sector+1]) {
                return sector
            }
        }
        return nil
    }
    
    func addDisc() {
        var frame = CGRect()
        frame.origin = CGPoint.zero
        frame.size = discSize!
        frame.origin.x = widthSectors![delegate!.moves.last!.action % 7]
        let discView = EllipseView(frame: frame)
        discView.index = delegate!.moves.last!.index
        discView.backgroundColor = delegate!.moves.last!.color == Color.red ? DISC_COLORS.red : DISC_COLORS.yellow
        discViews.append(discView)
        discBehavior!.addDrop(disc: discView)
    }
    
    func revealAllDiscsNumbers(winningPieces: [Int]) {
        for disc in discViews {
            disc.revealNumber(isWinning: winningPieces.contains(disc.action!))
        }
    }
    
    func clearBoard() {
        for view in discViews {
            discBehavior?.removeDrop(drop: view)
            view.removeFromSuperview()
        }
        discViews.removeAll()
    }
}

//From gravity bubble
class EllipseView: UIView {
    var index : Int?
    var action : Int?
    let fontColor = UIColor(red: 91/255, green: 3/255, blue: 0/255, alpha: 1)
    let highlightedColor = UIColor(red: 214/255, green: 238/255, blue: 255/255, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.size.width / 2.0
        layer.borderColor = fontColor.cgColor
        layer.borderWidth = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
    
    func revealNumber(isWinning: Bool) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 20))
        label.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        label.textAlignment = .center
        label.text = String(index!)
        if isWinning {
            label.textColor = highlightedColor
        }
        self.addSubview(label)
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}
