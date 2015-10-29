
import UIKit
import CoreData
import SwiftDDP

// Allows us to attach the list _id to the cell
public class TodoCell:UITableViewCell {
    var _id:String?
}


public class Todos: UITableViewController, NSFetchedResultsControllerDelegate, MeteorCoreDataCollectionDelegate {
    
    
    let meteor = (UIApplication.sharedApplication().delegate as! AppDelegate).meteor
    
    public var todos:MeteorCoreDataCollection = (UIApplication.sharedApplication().delegate as! AppDelegate).todos
    
    public var listId:String? {
        didSet {
            meteor.subscribe("todos", params: [listId!])
            try! fetchedResultsController.performFetch()
        }
    }
    
    private lazy var predicate:NSPredicate? = {
        if let _ = self.listId {
            return NSPredicate(format: "listId == '\(self.listId!)'")
        }
        return nil
    }()
    
    public lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        let primarySortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "listId", ascending: false)
        fetchRequest.sortDescriptors = [secondarySortDescriptor, primarySortDescriptor]
        if let _ = self.predicate { fetchRequest.predicate = self.predicate! }
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.todos.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    public override func viewDidLoad() {
        todos.delegate = self
        print("Todos name == \(todos.name)")
    }
    
    @IBOutlet weak var addTaskTextField: UITextField!
   
    // Insert the list
    @IBAction func add(sender: UIButton) {
        if let task = addTaskTextField.text where task != "" {
            let _id = meteor.getId()
            todos.insert(["_id":_id, "listId":listId!, "text":task] as NSDictionary)
            addTaskTextField.text = ""
        }
    }
    
    // MARK: - Table view data source

    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath) as! TodoCell
        let listItem = fetchedResultsController.objectAtIndexPath(indexPath)
        if let checked = listItem.valueForKey("checked") where checked as! Bool == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.textLabel?.text = listItem.valueForKey("text") as? String
        return cell
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = fetchedResultsController.objectAtIndexPath(indexPath)
        let id = object.valueForKey("id") as! String
        let checked = object.valueForKey("checked") as! Bool
        let update = ["checked":!checked]
        print("Update: \(update)")
        todos.update(id, fields: update)
    }
    
    override public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
            let id = object.valueForKey("id") as! String
            self.todos.remove(withId: id)
        }
    }
    
    //
    // NSFetchedResultsControllerDelegate method
    //
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
    
    //
    // MeteorCoreDataCollectionDelegate methods
    //
    
    public func document(willBeCreatedWith fields: NSDictionary?, forObject object: NSManagedObject) -> NSManagedObject {
        if let data = fields {
            for (key,value) in data {
                if !key.isEqual("createdAt") && !key.isEqual("_id") {
                    object.setValue(value, forKey: key as! String)
                }
            }
        }
        object.setValue(false, forKey: "checked")
        return object
    }
    
    public func document(willBeUpdatedWith fields: NSDictionary?, cleared: [String]?, forObject object: NSManagedObject) -> NSManagedObject {
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
