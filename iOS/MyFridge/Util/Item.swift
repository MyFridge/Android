import Foundation

class Item: NSObject {
    
    var key: String?
    var title: String?
    var desc: String?
    
    init?(key: String, title: String, desc: String) {
        guard !key.isEmpty || !title.isEmpty else {
            return nil
        }
        
        self.key = key
        self.title = title
        
        if !desc.isEmpty {
            self.desc = desc
        }
    }
}
