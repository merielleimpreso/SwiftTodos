# SwiftTodos
Meteor Todos created using SwiftDDP with CoreData integration.
Clone this repo, install SwiftDDP and run!

Note that connectivity to Meteor hosted instances of the todos app (*.meteor.com) can be erratic for several server-side reasons. If SwiftTodos does not connect (verifiable in the logs) or you cannot add or remove items or login, try connecting to a different instance. The easiest way to do this is to run an instance of the todos app locally.

```bash meteor create --example todos```

Once you've created and started the Meteor todos server, set the url variable in AppDelegate.swift to wss://localhost:3000/websocket, then run the iOS app.
