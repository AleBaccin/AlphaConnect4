//
//  BoardView.swift
//  Connect4
//
//  Created by Alessandro Baccin on 01/04/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit
import Alpha0Connect4

class BoardView : UIView {
    weak var delegate : GameDataSource?
    private var fillColor: UIColor = UIColor(red: 64/255, green: 61/255, blue: 88/255, alpha: 1)
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        //Draw the holed board
        let rect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let holedBoard = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        
        let width = self.frame.width / 7 - self.frame.width * 0.03
        let height = width
        
        for row in 0..<6 {
            for column in 0..<7 {
                let rect = CGRect(
                    x: CGFloat(column) * self.frame.width / 7 + (self.frame.width / 7) / 2 - width / 2 ,
                                  y: CGFloat(row) * self.frame.height / 6 + (self.frame.height / 6) / 2 - width / 2 ,
                                  width: width,
                                  height: height)
                let hole = UIBezierPath(ovalIn: rect)
                holedBoard.append(hole)
                holedBoard.usesEvenOddFillRule = true
            }
        }
        
        let board = CAShapeLayer()
        board.path = holedBoard.cgPath
        board.fillRule = .evenOdd
        board.fillColor = fillColor.cgColor
        self.layer.addSublayer(board)
        
        //Draw actual discs from the moves stored in delegate
        if let moves = delegate?.moves, !(delegate?.moves.isEmpty)! {
            for move in moves {
                let rect = CGRect(
                    x: CGFloat(move.action % 7) * self.frame.width / 7 + (self.frame.width / 7) / 2 - width / 2 ,
                    y: CGFloat(move.action / 7) * self.frame.height / 6 + (self.frame.height / 6) / 2 - width / 2 ,
                    width: width,
                    height: height)
                let hole = UIBezierPath(ovalIn: rect)
                (move.color == Color.red ? DISC_COLORS.red : DISC_COLORS.yellow).setFill()
                hole.fill()
            }
        }
    }
}
