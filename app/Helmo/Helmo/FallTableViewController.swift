//
//  FallTableViewController.swift
//  Helmo
//
//  Created by Mihnea Rusu on 09/03/17.
//  Copyright © 2017 Mihnea Rusu. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class FallTableViewController: UITableViewController  {
    
    var btManager: BluetoothManager! = nil
    var cellContents = [FallCellObject]()
    var currentOffset = 0
    var totalNumObjects = 0
    var isPopulatingCellContents = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFalls()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cellContents.removeAll()
        currentOffset = 0
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /**
     Load the falls from the web service.
     */
    func loadFalls() {
        WebServiceManager.sharedInstance.getFallCount() {
            (count: Int) in
            self.totalNumObjects = count
            print("\(#function): totalNumObjects \(self.totalNumObjects)")
        }
        
        guard self.totalNumObjects >= cellContents.count else {
            return
        }
        
        WebServiceManager.sharedInstance.getFalls(offset: currentOffset, onCompletion: populateCellContents)
    }
    
    /**
        Parse the contents from the JSON objects from the server into fall objects
     
        - Parameter json: JSON string from the server containing multiple fall objects
     */
    fileprivate func populateCellContents(json: JSON) {
        if json != JSON.null {
            isPopulatingCellContents = true
            for object in json.array! {
                self.cellContents.append(FallCellObject(json: object))
            }
            isPopulatingCellContents = false
            self.currentOffset = self.cellContents.count
        } else {
            print("\(#function): JSON response JSON.null.")
        } // end of if json != JSON.nukk
        
        DispatchQueue.main.async {
            print("\(#function): Reloading table cell data.")
            self.tableView.reloadData()
        }
    }
    
    // MARK: Table View Data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // override func t
    
    
    
    
    
}
