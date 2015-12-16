
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


class Lists: UITableViewController {
    
    @IBOutlet weak var loginButton: UIBarButtonItem!
    
    @IBAction func loginButtonWasClicked(sender: UIBarButtonItem) {
        if let _ = Meteor.client.userId() {
            logoutDialog()
        } else {
            self.performSegueWithIdentifier("loginDialog", sender: self)
        }
    }
    
    var collection:MeteorCollection = (UIApplication.sharedApplication().delegate as! AppDelegate).lists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = Meteor.client.userId() {
            loginButton.image = UIImage(named: "user_icon_selected")
        } else {
            loginButton.image = UIImage(named:"user_icon")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = Meteor.client.userId() {
            loginButton.image = UIImage(named: "user_icon_selected")
        } else {
            loginButton.image = UIImage(named:"user_icon")
        }

    }
    
    @IBOutlet weak var newListField: UITextField!
    
    @IBAction func addList(sender: AnyObject) {

        if let newList = newListField.text {
            let list = List(id: Meteor.client.getId(), fields: ["name": newList])
            collection.insert(list)
            newListField.text = ""
            self.tableView.reloadData()
        }
    }
    
    
    func logoutDialog() {
        
        let emailAddress = Meteor.client.user()
        let message = emailAddress != nil ? "Signed in as \(emailAddress!)." : "Signed in."
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .Destructive) { (action) in
            Meteor.logout()
            self.loginButton.image = UIImage(named:"user_icon")
        }
        alertController.addAction(signOutAction)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.barButtonItem = loginButton
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    func subscriptionReady() {
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return collection.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListCell
        
        let listItem = collection.sorted[indexPath.row]
        print("Cell -> \(listItem)")
        cell.textLabel?.text = listItem.valueForKey("name") as? String
        cell._id = listItem.valueForKey("id") as? String
        return cell
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "listsSegue") {
            let todosVC = (segue.destinationViewController as! UINavigationController).topViewController as! Todos
            let cell = (sender as! UITableViewCell)
            
            let indexPath = self.tableView.indexPathForCell(cell)
            let todo = collection.sorted[indexPath!.row]
            
            let id = todo.valueForKey("id") as? String
            let userId = todo.valueForKey("userId") as? String
            
            todosVC.listId = id!
            todosVC.title = cell.textLabel?.text
            
            if let _ = userId {
                todosVC.privateButton.image = UIImage(named: "locked_icon")
            } else {
                todosVC.privateButton.image = UIImage(named: "unlocked_icon")
            }
            
        }
    }
}
