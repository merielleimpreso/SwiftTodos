//
//  MeteorDocuments.swift
//  SwiftTodos
//
//  Created by Peter Siegesmund on 12/15/15.
//  Copyright © 2015 Peter Siegesmund. All rights reserved.
//

import Foundation
import SwiftDDP

class Todo: MeteorDocument {
    
    var collection:String = "todos"
    var listId:String = ""
    var text:String = ""
    var checked:Bool = false
    var createdAt:NSDate?
    
}

class List: MeteorDocument {
    
    var collection:String = "lists"
    var incompleteCount:Int = 0
    var name:String = ""
    var userId:String = ""
    
}