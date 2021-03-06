//
//  LocationStorage.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import CoreData

class LocationStorage:NSManagedObjectContext {
    
    private var maximumSave = 15
    static  let sharedInstance = LocationStorage()
    
    init() {
        super.init(concurrencyType:  .mainQueueConcurrencyType)
        self.persistentStoreCoordinator = CoreDataManager.sharedInstance.coordinator
        self.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        self.shouldDeleteInaccessibleFaults = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func deleteAllData() throws {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        
        let results = try self.fetch(fetchRequest) as! [NSManagedObject]
        _ = results.map({
            (result:NSManagedObject) in
            self.delete(result)
        })
        try self.save()
    }
    
    func printAllData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        
        do {
            let results = try self.fetch(fetchRequest) as! [LocationCD]
            
            for result in results {
                print(result.title!)
            }
        } catch {
            // gestion de l'err ici
        }
    }
    
    func getAllData() throws -> [LocationCD] {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try self.fetch(fetchRequest) as! [LocationCD]
    }
    
    func addLocation(location:Location) throws {
        
        let newEvent = NSEntityDescription.insertNewObject(forEntityName: "LocationCD", into: self) as! LocationCD
        
        newEvent.title = location.title
        newEvent.adress = location.adress
        newEvent.latitude = location.latitude
        newEvent.longitude = location.longitude
        newEvent.date = NSDate().timeIntervalSince1970
        
        try save()
        try removeIfNeeded()
    }
    
    func removeIfNeeded() throws {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationCD")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let results = try self.fetch(fetchRequest) as! [LocationCD]
        if results.count > maximumSave {
            let lastLocation = results.first!
            self.delete(lastLocation)
        }
        
        try self.save()
    }
}
