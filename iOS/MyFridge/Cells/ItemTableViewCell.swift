import UIKit

class ItemTableViewCell: UITableViewCell {

    var item: Item?
    
    let title: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 36.0)
        label.numberOfLines = 0
        return label
    }()
    
    let desc: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    fileprivate func setupView() {
        contentView.addSubview(title)
        title.anchor(top: contentView.safeAreaLayoutGuide.topAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 8, paddingLeft: 24, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        contentView.addSubview(desc)
        desc.anchor(top: title.bottomAnchor, left: contentView.safeAreaLayoutGuide.leftAnchor, bottom: contentView.safeAreaLayoutGuide.bottomAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 4, paddingLeft: 24, paddingBottom: -8, paddingRight: 8, width: 0, height: 0)
    }
}
