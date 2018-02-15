import UIKit
import FirebaseAuth
import FirebaseDatabase

class FridgeTableViewController: UITableViewController {
    
    var fridges = [Fridge]()
    var ref: DatabaseReference!
    
    let cellIdentifier = "FridgeTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fridges.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FridgeTableViewCell else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier)")
        }
        
        let index = indexPath.row
        let fridge = fridges[index]
        
        cell.fridge = fridge
        cell.title.text = fridge.title
        cell.desc.text = fridge.desc
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCellTouched))
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let fridge = fridges[indexPath.row]
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let alert = UIAlertController(title: "Edit \"\(fridge.title!)\"", message: "\"\(fridge.desc!)\"", preferredStyle: .alert)
            alert.addTextField { (textField) -> Void in
                textField.placeholder = "Title"
                textField.text = fridge.title!
            }
            alert.addTextField { (textField) -> Void in
                textField.placeholder = "Description"
                if fridge.desc!.count > 0 {
                    textField.text = fridge.desc!
                }
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
                (_) in
                let title = alert.textFields?[0].text
                let desc = alert.textFields?[1].text
                
                if title!.count > 0 {
                    self.ref.child((Auth.auth().currentUser?.uid)!).child("fridges").child(fridge.key!).updateChildValues([ "name": title!, "description": desc! ])
                } else {
                    let extraAlert = UIAlertController(title: "Error", message: "A title is required!", preferredStyle: .alert)
                    extraAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(extraAlert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        edit.backgroundColor = UIColor.rgb(red: 76, green: 217, blue: 100)
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            
        }
        share.backgroundColor = UIColor.rgb(red: 0, green: 122, blue: 255)
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            var title = "Delete"
            
            if !fridge.isMine! {
                title = "Leave"
            }
            
            let alert = UIAlertController(title: title, message: "Do you want to \(title.lowercased()) this Fridge?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
            (_) in
                self.ref.child((Auth.auth().currentUser?.uid)!).child("fridges").child(fridge.key!).removeValue();
            }))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.rgb(red: 255, green: 59, blue: 48)
        
        if !fridge.isMine! {
            delete.title = "Leave"
            return [ delete ]
        } else {
            return [ delete, edit ]
        }
    }
 
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func handleCellTouched(sender: UITapGestureRecognizer) {
        let tapLocaiton = sender.location(in: tableView)
        let index = tableView.indexPathForRow(at: tapLocaiton)
        let cell = tableView.cellForRow(at: index!) as! FridgeTableViewCell
        
        let fridge: Fridge = cell.fridge!
        let itemTable = ItemTableViewController()
        
        itemTable.fridge = fridge
        itemTable.title = fridge.title!
        
        if !fridge.isMine! {
            ref.child((Auth.auth().currentUser?.uid)!).child("fridges").child(fridge.key!).observeSingleEvent(of: .value, with: { (snapshot) in
                itemTable.owner = snapshot.value as! String
                
                self.navigationController?.pushViewController(itemTable, animated: true)
            })
        } else {
            self.navigationController?.pushViewController(itemTable, animated: true)
        }
    }
    
    @objc func handleAdd() {
        let alert = UIAlertController(title: "Add Fridge", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Title"
        }
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Description"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: {
            (_) in
            let title = alert.textFields?[0].text
            let desc = alert.textFields?[1].text
            
            if title!.count > 0 {
                let key = self.ref.child((Auth.auth().currentUser?.uid)!).child("fridges").childByAutoId().key
                self.ref.child((Auth.auth().currentUser?.uid)!).child("fridges").child(key).setValue([ "name": title!, "description": desc! ])
            } else {
                let extraAlert = UIAlertController(title: "Error", message: "A title is required!", preferredStyle: .alert)
                extraAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(extraAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    fileprivate func setupView() {
        title = "My Fridges"
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let logout = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.leftBarButtonItem = logout
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = add
        
        tableView.register(FridgeTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        loadFridges()
    }

    fileprivate func loadFridges() {
        ref.child((Auth.auth().currentUser?.uid)!).child("fridges").observe(.value, with: { (snapshot) in
            self.fridges = [Fridge]()
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                if childSnapshot.hasChildren() {
                    let key = childSnapshot.key
                    let title = childSnapshot.childSnapshot(forPath: "name").value as? String ?? ""
                    let desc = childSnapshot.childSnapshot(forPath: "description").value as? String ?? ""
                    
                    let fridge = Fridge(key: key, title: title, desc: desc, isMine: true)
                    
                    self.fridges.append(fridge!)
                } else {
                    let fridgeKey: String = childSnapshot.key
                    let fridgeOwner: String = childSnapshot.value as! String
                    
                    self.ref.child(fridgeOwner).child("fridges").child(fridgeKey).observeSingleEvent(of: .value, with: { (snapshot) in
                        let title = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                        let desc = snapshot.childSnapshot(forPath: "description").value as? String ?? ""
                        
                        let fridge = Fridge(key: fridgeKey, title: title, desc: desc, isMine: false)
                        
                        self.fridges.append(fridge!)
                        
                        self.tableView.reloadData()
                    })
                }
            }
            
            self.tableView.reloadData()
        })
    }
}
