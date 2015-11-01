
import UIKit
import CoreData
import SwiftDDP

//
// This class defines the table of lists
//

// Allows us to attach the list _id to the cell
public class ListCell:UITableViewCell {
    var _id:String?
}


class Lists: MeteorCoreDataTableViewController, MeteorCoreDataCollectionDelegate {
    
    let meteor = (UIApplication.sharedApplication().delegate as! AppDelegate).meteor
    var collection:MeteorCoreDataCollection = (UIApplication.sharedApplication().delegate as! AppDelegate).lists
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "List")
        let primarySortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [secondarySortDescriptor, primarySortDescriptor]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.collection.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    @IBOutlet weak var newListField: UITextField!
    
    @IBAction func addList(sender: AnyObject) {
        let list = (UIApplication.sharedApplication().delegate as! AppDelegate).lists

        if let newList = newListField.text {
            list.insert(["_id":meteor.getId(), "name":newList])
            newListField.text = ""
        }
    }
    
    
    func subscriptionReady() {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListCell
        
        let listItem = fetchedResultsController.objectAtIndexPath(indexPath)
        cell.textLabel?.text = listItem.valueForKey("name") as? String
        cell._id = listItem.valueForKey("id") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            let id = object.valueForKey("id") as! String
            self.collection.remove(withId: id)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "listsSegue") {
            let todosVC = segue.destinationViewController as! Todos
            todosVC.listId = (sender as! ListCell)._id!
        }
    }
    
    /*
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Move: print("> Move"); if indexPath!.isEqual(newIndexPath!) == false {
            self.tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        } else {
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        case .Delete: print("> Delete"); self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Insert: print("> Insert"); self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update: print("> Update"); self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    */
    
    func document(willBeCreatedWith fields: NSDictionary?, forObject object: NSManagedObject) -> NSManagedObject {
        if let data = fields {
            for (key,value) in data {
                if !key.isEqual("createdAt") && !key.isEqual("_id") {
                    object.setValue(value, forKey: key as! String)
                }
            }
        }
        return object
    }
    
    func document(willBeUpdatedWith fields: NSDictionary?, cleared: [String]?, forObject object: NSManagedObject) -> NSManagedObject {
        if let _ = fields {
            for (key,value) in fields! {
                object.setValue(value, forKey: key as! String)
            }
        }
        
        if let _ = cleared {
            for field in cleared! {
                object.setNilValueForKey(field)
            }
        }
        return object
    }

    
}
