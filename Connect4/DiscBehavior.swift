//
//  DiscBehavior.swift
//  Connect4
//
//  Created by Alessandro Baccin on 01/04/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit

class DiscBehavior: UIDynamicBehavior {
    let gravity = UIGravityBehavior()
    lazy var collider: UICollisionBehavior =  {
       let collider = UICollisionBehavior()
       collider.translatesReferenceBoundsIntoBoundary = true
       return collider
    }()
    
    lazy var dropBehavior: UIDynamicItemBehavior = {
        let dropBehavior = UIDynamicItemBehavior()
        dropBehavior.allowsRotation = false
        dropBehavior.friction = 0.1
        dropBehavior.allowsRotation = true
        dropBehavior.elasticity = 0.15
        dropBehavior.density = 0.8
        return dropBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(dropBehavior)
    }
    
    func addDrop(disc: EllipseView) {
        dynamicAnimator?.referenceView?.addSubview(disc)
        gravity.addItem(disc)
        collider.addItem(disc)
        dropBehavior.addItem(disc)
    }
    
    func removeDrop(drop: EllipseView) {
        gravity.removeItem(drop)
        collider.removeItem(drop)
        dropBehavior.removeItem(drop)
        drop.removeFromSuperview()
    }
}
