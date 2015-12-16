
import UIKit
import CoreData
import SwiftDDP

// Allows us to attach the list _id to the cell
public class TodoCell:UITableViewCell {
    var _id:String?
}


class Todos: UITableViewController {
    
    @IBOutlet weak var privateButton: UIBarButtonItem!
    
    @IBAction func makeListPrivate(sender: UIBarButtonItem) {
        /*
        if let userId = Meteor.client.userId() {
            
            if let objectUserId = lists.findOne(listId!)?.valueForKey("userId") as? String where (objectUserId == userId)  {
                lists.update(listId!, fields: ["userId": "true"], action:"$unset")
                privateButton.image = UIImage(named: "unlocked_icon")
            } else {
                lists.update(listId!, fields: ["userId": userId])
                privateButton.image = UIImage(named: "locked_icon")
            }
            
        } else {
            print("You must be logged in to make a list private")
        }
        */
    }
    
    let collection:MeteorCollection = (UIApplication.sharedApplication().delegate as! AppDelegate).todos
    // let lists:MeteorCoreDataCollection = (UIApplication.sharedApplication().delegate as! AppDelegate).lists
    
    var listId:String? {
        didSet {
            Meteor.subscribe("todos", params: [listId!]) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        Meteor.unsubscribe("todos")
    }
    
    @IBOutlet weak var addTaskTextField: UITextField!
   
    // Insert the list
    @IBAction func add(sender: UIButton) {
        if let task = addTaskTextField.text where task != "" {
            let _id = Meteor.client.getId()
            let todo = Todo(id:_id, fields: ["listId":listId!, "text":task])
            collection.insert(todo)
            addTaskTextField.text = ""
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath) as! TodoCell
        let todo = collection.sorted[indexPath.row]
        if let checked = todo.valueForKey("checked") where checked as! Bool == true {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        cell.textLabel?.text = todo.valueForKey("text") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = collection.sorted[indexPath.row]
        object.checked = true
        collection.update(object)
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let object = collection.sorted[indexPath.row]
            self.collection.remove(object)
            self.tableView.reloadData()
        }
    }
 }
