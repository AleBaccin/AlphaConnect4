//
//  ReplayVC.swift
//  Connect4
//
//  Created by Alessandro Baccin on 27/03/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit
import Alpha0Connect4

class ReplayVC : UIViewController, UIDynamicAnimatorDelegate, GameDataSource {
    var moves = [(action: Int, color: Color, index: Int)]()
    
    private let discBehavior = DiscBehavior()
    var game : Game?
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: gameView)
        animator.delegate = self
        return animator
    }()
    
    //MARK: - Properties
    @IBOutlet weak var boardView: BoardView! {didSet {
        boardView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var gameView: GameView! {didSet {
        gameView.delegate = self
        gameView.discBehavior = discBehavior
        }
    }
    @IBOutlet weak var restartButton: UIBarButtonItem!
    
    @IBAction func restart(_ sender: Any) {
        print("Cleaning board")
        gameView.clearBoard()
        updateUI()
    }
    
    private func disableAllInteractions() {
        restartButton.isEnabled = false
        gameView.gestureRecognizers!.forEach( {$0.isEnabled = false})
    }
    
    private func enableAllInteractions() {
        restartButton.isEnabled = true
        gameView.gestureRecognizers!.forEach( {$0.isEnabled = true})
    }
    
    private func moveHandler(move: (action: Int, color: Color, index: Int, isWinning: Bool)) {
        moves.append((move.action, move.color, move.index))
        guard let lastMove = self.moves.last else {
            print("ERROR: could not retrieve the last USER move")
            enableAllInteractions()
            return
        }
        gameView.addDisc()
        gameView.discViews.last?.action = lastMove.action
        guard let disc = gameView.discViews.last else {
            return
        }
        disc.revealNumber(isWinning: move.isWinning)
    }
    
    private func updateUI() {
        var sortedMoves = [(action: Int, color: Color, index: Int, isWinning: Bool)?]()
        for case let move as Move in (game?.moves!.allObjects)! {
            print("action: \(move.action), color: \(move.color ?? "ERROR"), index: \(move.index)")
            sortedMoves.append((Int(move.action), move.color == "red" ? Color.red : Color.yellow, Int(move.index), move.isWinning))
        }
        
        sortedMoves.sort(by: { $0!.index > $1!.index })
        disableAllInteractions()
        
        var timer = Timer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            actions in
            if sortedMoves.isEmpty {
                print("END")
                self.enableAllInteractions()
                timer.invalidate()
                return
            }
            else {
                self.moveHandler(move: sortedMoves.removeLast()!)
            }
        }
        print("End of replay")
        print("\(game!.winner ?? "ERROR: can't extract winner") with \(game!.moves?.count ?? -1) moves")
    }
    
    //MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Replay"
        animator.addBehavior(discBehavior)
        boardView.layer.zPosition = 1
        gameView.layer.zPosition = 0
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !gameView.hasBoundaries() {
            gameView.addBoundaries(bottom: CGPoint.init(x: 0, y: boardView.frame.origin.y + boardView.frame.height))
        }
    }
}
