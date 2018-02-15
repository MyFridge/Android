import UIKit
import FirebaseAuth
import FirebaseDatabase

class ItemTableViewController: UITableViewController {

    var owner: String?
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
                var uid = Auth.auth().currentUser?.uid
                
                if !(self.fridge?.isMine)! {
                    uid = self.owner
                }
                
                let key = self.ref.child(uid!).child("fridges").child((self.fridge?.key)!).child("items").childByAutoId().key
                self.ref.child(uid!).child("fridges").child((self.fridge?.key)!).child("items").child(key).setValue([ "name": title!, "description": desc! ])
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
        var uid = Auth.auth().currentUser?.uid
        
        if !(fridge?.isMine)! {
            uid = owner
        }
        
        ref.child(uid!).child("fridges").child((fridge?.key)!).child("items").observe(.value, with: { (snapshot) in
            self.items = [Item]()
            
            print(uid)
            print(self.fridge?.key)
            print(snapshot.children.allObjects.count)
            
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! DataSnapshot
                
                let key = childSnapshot.key
                let title = childSnapshot.childSnapshot(forPath: "name").value as? String ?? ""
                let desc = childSnapshot.childSnapshot(forPath: "description").value as? String ?? ""
                
                let item = Item(key: key, title: title, desc: desc)
                
                self.items.append(item!)
            }
            
            self.tableView.reloadData()
        })
    }
}
