//
//  ViewController.swift
//  Connect4
//
//  Created by COMP47390 on 09/01/2020.
//  Copyright © 2020 COMP47390. All rights reserved.
//

import UIKit
import Alpha0Connect4
import CoreData

var BOARD_SIZES = (rows: 6, columns: 7)
var DISC_COLORS = (yellow: UIColor(red: 219/255, green: 213/255, blue: 110/255, alpha: 1),
                   red: UIColor(red: 252/255, green: 119/255, blue: 83/255, alpha: 1))

class GameVC: UIViewController, UIDynamicAnimatorDelegate, GameDataSource {
    private let discBehavior = DiscBehavior()
    private let gameModel = GameModel()
    private var playerUIColor = DISC_COLORS.yellow
    private var botUIColor = DISC_COLORS.red
    private var userTurn : Bool = false
    private var restarting : Bool = false
    
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: gameView)
        animator.delegate = self
        return animator
    }()
    
    private func disableAllInteractions() {
        restartButton.isEnabled = false
        gameView.gestureRecognizers!.forEach( {$0.isEnabled = false})
    }
    
    private func enableAllInteractions() {
        restartButton.isEnabled = true
        gameView.gestureRecognizers!.forEach( {$0.isEnabled = true})
    }
    
    private func enableRestart() {
        restartButton.isEnabled = true
        swipeGestureRecognizer.isEnabled = true
    }
    
    // MARK: - Delegate pattern
    internal var moves = [(action: Int, color: Color, index: Int)]()
    
    // MARK: - Properties, Actions and Alerts
    @IBOutlet weak var victoryLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var boardView: BoardView! {didSet {
        boardView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var gameView: GameView! {didSet {
        gameView.discBehavior = discBehavior
        gameView.delegate = self
        }
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        print("\(sender.location(in: gameView))")
        // do something like drop a bubble
        columnIndex = gameView.resolveSector(point: sender.location(in: gameView).x)
    }
    
    @IBAction func restartAction(_ sender: Any) {
        gameView.removeBoundaries()
        print("Cleaning board")
        restarting = true
        victoryLabel?.isHidden = true
        
        //We can't w8 for animatorDidStop cause there are not discs
        if moves.isEmpty {
            moves.removeAll()
            gameModel.restart()
            gameView.clearBoard()
            gameView.addBoundaries(bottom: CGPoint.init(x: 0, y: boardView.frame.origin.y + boardView.frame.height))
            pickWhoStarts()
            restarting = false
        }
    }
    
    private func pickWhoStarts() {
        let victoryAlert = UIAlertController(title: "Who's going first?", message: "Please select.", preferredStyle: UIAlertController.Style.alert)
        
        victoryAlert.addAction(UIAlertAction(title: "You", style: UIAlertAction.Style.default, handler: { action in
            DispatchQueue.main.async{
                self.userTurn = true
                self.playGame()
            }
        }))
        victoryAlert.addAction(UIAlertAction(title: "AlphaC4", style: UIAlertAction.Style.default, handler: { action in
            DispatchQueue.main.async{
                self.userTurn = false
                self.playGame()
            }
        }))
        
        present(victoryAlert, animated: true, completion: nil)
    }
    
    //MARK: - AnimatorDidPause
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        print("animation paused")
        
        //Actual restart routine
        if restarting {
            moves.removeAll()
            gameModel.restart()
            gameView.clearBoard()
            gameView.addBoundaries(bottom: CGPoint.init(x: 0, y: boardView.frame.origin.y + boardView.frame.height))
            pickWhoStarts()
            restarting = false
        }
        else if !userTurn && !gameModel.isGameDone() && !moves.isEmpty {
            print("bot moves")
            userTurn = true
            moveHandler(move: gameModel.botMoves()!)
            endTurnRoutine()
        }
        else {
            enableAllInteractions()
        }
    }
    
    //MARK: - UpdateMoves
    private var columnIndex : Int? {
        didSet {
            disableAllInteractions()
            
            if userTurn {
                if !gameModel.isGameDone() {
                    guard let userMove = gameModel.userMoves(column: columnIndex!) else {
                        print("ERROR: Wrong move")
                        enableAllInteractions()
                        return
                    }
                    print("user moves")
                    userTurn = false
                    moveHandler(move: userMove)
                    endTurnRoutine()
                }
            }
            
            enableRestart()
        }
    }
    
    // MARK: - Play game
    private func playGame() {
        //To prevent quick double clicking at game's start
        if !userTurn {
            disableAllInteractions()
        }
        
        guard let firstBotMove = gameModel.startGame(userTurn: userTurn) else {
            endTurnRoutine()
            return
        }
        userTurn = true
        moveHandler(move: firstBotMove)
        endTurnRoutine()
    }
    
    private func moveHandler(move: (action: Int, color: Color, index: Int)) {
        moves.append(move)
        guard let lastBotMove = moves.last else {
            print("ERROR: could not retrieve the last USER move")
            return
        }
        gameView.addDisc()
        gameView.discViews.last?.action = lastBotMove.action
    }
    
    private func endTurnRoutine() {
        guard let outcome = gameModel.outCome, gameModel.isGameDone() else {
            return
        }
        
        //in case of Victory
        updateCoreData(outcome: outcome)
        victoryLabel?.text = outcome.message
        victoryLabel?.isHidden = false
        gameView.revealAllDiscsNumbers(winningPieces: outcome.winningPieces)
        enableRestart()
    }
    
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.addBehavior(discBehavior)
        self.title = "UCD AlphaC4"
        boardView.layer.zPosition = 1
        gameView.layer.zPosition = 0
        printCoreDataStats()
        victoryLabel?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !gameView.hasBoundaries() {
            gameView.addBoundaries(bottom: CGPoint.init(x: 0, y: boardView.frame.origin.y + boardView.frame.height))
        }
        
        if moves.isEmpty && !userTurn {
            pickWhoStarts()
        }
    }
}


// MARK: - CoreData Persistence
fileprivate extension GameVC {
    private func updateCoreData(outcome: (message: String, winningPieces: [Int])?) {
        print("updating coredata")
        container?.performBackgroundTask { context in
            let game = NSEntityDescription.insertNewObject(forEntityName: "Game", into: context) as! Game
            game.id = UUID()
            game.numberOfMoves = Int16(self.moves.count)
            game.winner = outcome?.message
            game.date = Date()
            
            for x in self.moves {
                let move = NSEntityDescription.insertNewObject(forEntityName: "Move", into: context) as! Move
                
                move.action = Int16(x.action)
                move.color = x.color == Color.red ? "red" : "yellow"
                move.index = Int16(x.index)
                move.ofGame = game
                move.isWinning = outcome!.winningPieces.contains(x.action)
            }
            
            do { try context.save() }
            catch { print("Saving Failed") }
            print("coredata update completed")
            self.printCoreDataStats()
        }
    }
    
    private func printCoreDataStats() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread { print("on main thread") }
                else { print("off main thread") }
                
                if let gamesCount = try? context.count(for: NSFetchRequest<Game>(entityName: "Game")) {
                    print("\(gamesCount) games")
                }
                
                if let movesCount = try? context.count(for: NSFetchRequest<Move>(entityName: "Move")) {
                    print("\(movesCount) moves")
                }
            }
        }
    }
}
