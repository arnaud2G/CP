//
//  CoreDataManager.swift
//  CP
//
//  Created by 2Gather Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let sharedInstance = CoreDataManager()
    
    let modelName = "CP"
    
    // Définition de l'URL de l'emplacement de sauvegarde
    lazy var storeDirectory: URL = {
        
        let fm = FileManager.default
        
        let urls = fm.urls(for: .documentDirectory, in:.userDomainMask)
        
        return urls.first!
        
    }()
    
    // Retourne l'url de la base locale
    lazy var localStoreURL: URL = {
        let url = self.storeDirectory.appendingPathComponent("CP.sqlite")
        return url
    }()
    
    // Définition de l'url du model
    lazy var modelURL: URL = {
        
        // Test la présence du fichier momd
        let bundle = Bundle.main
        if let url = bundle.url(forResource: self.modelName, withExtension: "momd") {
            return url
        }
        
        print("CRITICAL - Managed Object Model fil not found")
        
        abort()
        
    }()
    
    // Retourne le model associé au fichier momd
    lazy var model: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOf: self.modelURL)!
    }()
    
    // Retourne le coordinateur (model -> local)
    lazy var coordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let mOption = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.localStoreURL, options: mOption)
        } catch {
            print("Could not add the persistent store")
            abort()
        }
        
        return coordinator
    }()
    
}
