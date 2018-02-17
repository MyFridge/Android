import UIKit
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        return label
    }()
    
    let name: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 36.0)
        tf.placeholder = "Name"
        return tf
    }()
    
    let uidLabel: UILabel = {
        let label = UILabel()
        label.text = "UID"
        return label
    }()
    
    let uid: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 36.0)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveUser()
    }

    fileprivate func setupView() {
        title = "Profile"
        
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 19.5, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        view.addSubview(name)
        name.anchor(top: nameLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 19.5, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        view.addSubview(uidLabel)
        uidLabel.anchor(top: name.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 24, paddingLeft: 19.5, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        view.addSubview(uid)
        uid.anchor(top: uidLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 19.5, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleUIDTouched))
        tap.delegate = self
        uid.addGestureRecognizer(tap)
    }
    
    @objc func handleUIDTouched() {
        let shareContent:String = (Auth.auth().currentUser?.uid)!
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: {})
    }
    
    fileprivate func loadUser() {
        uid.text = Auth.auth().currentUser?.uid
        
        ref.child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { snapshot in
            self.name.text = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
        })
    }
    
    fileprivate func saveUser() {
        if !name.text!.isEmpty {
            ref.child(Auth.auth().currentUser!.uid).child("name").setValue(name.text)
        }
    }
}
