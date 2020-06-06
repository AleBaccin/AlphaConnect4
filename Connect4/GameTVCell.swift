//
//  GameTVCell.swift
//  Connect4
//
//  Created by Alessandro Baccin on 28/03/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit
import Alpha0Connect4

class GameTVCell : UITableViewCell, GameDataSource {
    var game : Game? { didSet {
        moves.removeAll()
        for case let move as Move in (game?.moves!.allObjects)! {
            moves.append((Int(move.action), move.color == "red" ? Color.red : Color.yellow, Int(move.index)))
        }
        updateUI()
        }
    }
    
    internal var moves = [(action: Int, color: Color, index: Int)]()
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var boardView: BoardView! {didSet {
        boardView.backgroundColor = .clear
        }
    }
    
    private func updateUI() {
        boardView.delegate = self
        boardView.setNeedsDisplay()
        
        winnerLabel.text = game?.winner
        movesLabel.text = "Game ended in \(game!.numberOfMoves) moves"
        if let saveAt = game?.date {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(saveAt) > 24*60*60 {
                formatter.dateStyle = .short
            }
            else {
                formatter.timeStyle = .short
            }
            let time = formatter.string(from: saveAt)
            dateLabel?.text = time
        }
        
        print("\(game!.winner ?? "ERROR: can't extract winner") with \(game!.moves?.count ?? -1) moves")
    }
}
