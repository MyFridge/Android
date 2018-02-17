import UIKit

class AlertPickerViewController: UIViewController {
    
    let effectView: UIVisualEffectView = {
        let vev = UIVisualEffectView(effect: UIBlurEffect())
        return vev
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    fileprivate func setupView() {
        view.backgroundColor = nil
        
        view.addSubview(effectView)
        effectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
}
