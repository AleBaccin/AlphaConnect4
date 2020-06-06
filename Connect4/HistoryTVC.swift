//
//  HistoryTVC.swift
//  Connect4
//
//  Created by Alessandro Baccin on 27/03/2020.
//  Copyright © 2020 CS UCD. All rights reserved.
//

import UIKit
import CoreData

class HistoryTVC : CoreDataTVC {
    fileprivate var fetchedResultsController: NSFetchedResultsController<Game>?
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    // MARK: - Segue Identifiers
    private struct Identifiers {
        static let showReplay : String = "showReplay"
    }
    
    private func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Game> = Game.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            
            fetchedResultsController = NSFetchedResultsController<Game>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try? fetchedResultsController?.performFetch()
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameTVCell", for: indexPath) as! GameTVCell
        if let game = fetchedResultsController?.object(at: indexPath) {
            cell.game = game
        }
        return cell
    }
    // MARK: - VC lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        self.title = "History"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        updateUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Identifiers.showReplay:
            let destinationVC = segue.destination as! ReplayVC
            let cell = sender as! GameTVCell
            destinationVC.game = cell.game
        default:
            break
        }
    }
}

extension HistoryTVC {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }
        else {
            return 0
        }
    }
}
