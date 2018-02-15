import Foundation

class Fridge: NSObject {
    
    var key: String?
    var title: String?
    var desc: String?
    var isMine: Bool?
    
    init?(key: String, title: String, desc: String, isMine: Bool) {
        guard !key.isEmpty || !title.isEmpty else {
            return nil
        }
        
        self.key = key
        self.title = title
        self.isMine = isMine
        
        if !desc.isEmpty {
            self.desc = desc
        } else {
            self.desc = ""
        }
    }
}
