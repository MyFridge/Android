import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let phoneLogin: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login with Phone Number", for: .normal)
        button.addTarget(self, action: #selector(handlePhoneLogin), for: .touchUpInside)
        return button
    }()
    
    let info: UILabel = {
        let label = UILabel()
        label.text = "If you do not already have an account, one will be created for you at login"
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var handler: AuthStateDidChangeListenerHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.present(NavigationController(), animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handler!)
    }
    
    
    @objc func handlePhoneLogin() {
        let alert = UIAlertController(title: "Login with Phone Number", message: "Please enter your phone number.", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.keyboardType = .phonePad
            textField.placeholder = "Phone Number"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
            (_) in
            let phoneNumber = alert.textFields?[0].text
            UserDefaults.standard.set(phoneNumber!, forKey: "phoneNumber")
            self.sendVerificationCode(phoneNumber: phoneNumber!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setupView() {
        view.addSubview(phoneLogin)
        phoneLogin.centerInView(view: view)
        
        view.addSubview(info)
        info.anchor(top: nil, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: -8, paddingRight: 8, width: 0, height: 0)
    }
    
    fileprivate func sendVerificationCode(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber("+1\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error: \(error)")
                // TODO: Show error
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            self.verifyPhoneNumber(verificationID: verificationID!)
        }
    }
    
    fileprivate func verifyPhoneNumber(verificationID: String) {
        let alert = UIAlertController(title: "Verification Code", message: "Please enter your verification code.", preferredStyle: .alert)
        alert.addTextField { (textField) -> Void in
            textField.keyboardType = .numberPad
            textField.placeholder = "Verification Code"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
            (_) in
            let verificationCode = alert.textFields?[0].text
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode!)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print("Error: \(error)")
                    let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber")
                    self.sendVerificationCode(phoneNumber: phoneNumber!)
                    return
                }
                
                UserDefaults.standard.removeObject(forKey: "authVerificationID")
                // TODO: Load next view
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

