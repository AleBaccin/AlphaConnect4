//
//  GameModel.swift
//  Connect4
//
//  Created by Alessandro Baccin on 26/03/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//
//Class existing to simply the usage of the Alpha connect4 API

import Alpha0Connect4

protocol GameDataSource : class {
    var moves : [(action: Int, color: Color, index: Int)] {get set}
}

class GameModel {
    private let gameSession = GameSession()
    var outCome : (message: String, winningPieces : [Int])? { get{
        return gameSession.outcome
        }
    }
    
    func startGame(userTurn: Bool) -> (action: Int, color: Color, index: Int)? {
        gameSession.botStarts = !userTurn
        if gameSession.botStarts {
            if let move = gameSession.move {
                return move
            }
        }
        return nil
    }
    
    func userMoves(column: Int) -> (action: Int, color: Color, index: Int)? {
        if gameSession.userPlay(at: column) {
            if let move = gameSession.move {
                return move
            }
        }
        return nil
    }
    
    func botMoves() -> (action: Int, color: Color, index: Int)? {
        if let move = gameSession.move {
            return move
        }
        return nil
    }
    
    func isGameDone() -> Bool {
        return gameSession.done
    }
    
    func restart() {
        do { try gameSession.clear() }
        catch { print("ERROR: Could not restart gameSession") }
    }
}
