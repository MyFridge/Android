import Foundation

class Alert: NSObject {
    
    enum type: Int {
        case none = 0
        case low = 1
        case need = 2
        case full = 3
        case want = 4
    }
    
    var type: Alert.type!
    
    init?(type: Alert.type) {
        self.type = type
    }
    
    func toString() -> String {
        switch self.type.rawValue {
        case Alert.type.none.rawValue:
            return "All out"
        case Alert.type.low.rawValue:
            return "Low"
        case Alert.type.need.rawValue:
            return "Need"
        case Alert.type.full.rawValue:
            return "Full"
        case Alert.type.want.rawValue:
            return "Want"
        default:
            return ""
        }
    }
}
