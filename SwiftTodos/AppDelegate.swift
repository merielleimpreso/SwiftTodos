
import UIKit
import SwiftDDP
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let meteor = Meteor.client
    
    // Define collections once in the app delegate
    //let lists = RealmCollection<List>(name: "lists")
    let todos = MeteorCoreDataCollection(collectionName: "todos", entityName: "Todo")
    let lists = MeteorCoreDataCollection(collectionName: "lists", entityName: "List")
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        meteor.logLevel = .Debug
        let url = "wss://todos.meteor.com/websocket"
        meteor.connect(url) { session in
            
            self.meteor.subscribe("publicLists") {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "lists_loaded", object: nil))
            }
            
            self.meteor.subscribe("privateLists") {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "lists_loaded", object: nil))
            }
        }
        
        return true
    }
    
        // MARK: - Core Data Saving support
    /*
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }*/


}

