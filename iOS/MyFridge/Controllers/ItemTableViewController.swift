import UIKit
import FirebaseAuth
import FirebaseDatabase

class ItemTableViewController: UITableViewController {

    var fridge: Fridge?
    var items = [Item]()
    var ref: DatabaseReference!
    
    let cellIdentifier = "ItemTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        setupView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ItemTableViewCell else {
            fatalError("The dequeued cell is not an instance of \(cellIdentifier)")
        }
        
        let index = indexPath.row
        let item = items[index]
        
        cell.item = item
        cell.title.text = item.title
        cell.desc.text = item.desc
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = items[indexPath.row]
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let alert = UIAlertController(title: "Edit \"\(item.title!)\"", message: "\"\(item.desc ?? "")\"", preferredStyle: .alert)
            alert.addTextField { (textField) -> Void in
                textField.placeholder = "Title"
                textField.text = item.title!
            }
            alert.addTextField { (textField) -> Void in
                textField.placeholder = "Description"
                textField.text = item.desc ?? ""
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            /* alert.addAction(UIAlertAction(title: "Set Alerts", style: UIAlertActionStyle.default, handler: {
                (_) in
                
                let alertPicker = AlertPickerViewController()
                
                alertPicker.providesPresentationContextTransitionStyle = true;
                alertPicker.definesPresentationContext = true;
                alertPicker.modalPresentationStyle = .overCurrentContext;
                
                self.present(alertPicker, animated: true, completion: nil)
            })) */
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
                (_) in
                let title = alert.textFields?[0].text
                let desc = alert.textFields?[1].text
                
                if title!.count > 0 {
                    self.ref.child("fridges").child((self.fridge?.key)!).child("items").child((item.key)!).updateChildValues([ "name": title!, "description": desc! ])
                } else {
                    let extraAlert = UIAlertController(title: "Error", message: "A title is required!", preferredStyle: .alert)
                    extraAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(extraAlert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        edit.backgroundColor = UIColor.rgb(red: 76, green: 217, blue: 100)
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let alert = UIAlertController(title: "Delete \"\(item.title!)\"", message: "Do you want to delete this item?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {
                (_) in
                self.ref.child("fridges").child((self.fridge?.key)!).child("items").child((item.key)!).removeValue();
            }))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.rgb(red: 255, green: 59, blue: 48)
        
        return [ delete, edit ]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func handleAdd() {
        let alert = UIAlertController(title: "Add Item", message: "Add item to \"\(fridge?.title ?? "")\"", preferredStyle: .alert)
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
                let key = self.ref.child("fridges").child((self.fridge?.key)!).child("items").childByAutoId().key
                self.ref.child("fridges").child((self.fridge?.key)!).child("items").child(key).setValue([ "name": title!, "description": desc! ])
            } else {
                let extraAlert = UIAlertController(title: "Error", message: "A title is required!", preferredStyle: .alert)
                extraAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(extraAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupView() {
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAdd))
        navigationItem.rightBarButtonItem = add
        
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        loadItems()
    }
    
    fileprivate func loadItems() {
        ref.child("fridges").child((fridge?.key)!).child("items").observe(.value, with: { (snapshot) in
            self.items = [Item]()
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                let key = childSnapshot.key
                let title = childSnapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let desc = childSnapshot.childSnapshot(forPath: "description").value as? String ?? ""
                
                let item = Item(key: key, title: title, desc: desc)
                
                self.items.append(item!)
                self.items.sort(by: { $0.title! < $1.title! })
                
                self.tableView.reloadData()
            }
        })
    }
}
