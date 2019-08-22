import UIKit

class Atom: NSObject {
    var id = Int()
    var symb = String()
    var color = UIColor()
    var x = Float()
    var y = Float()
    var z = Float()
    var connections = [Int()]
    
    init(id: Int, symb: String, color: UIColor, x: Float, y: Float, z: Float) {
        self.id = id
        self.symb = symb
        self.color = color
        self.x = x
        self.y = y
        self.z = z
    }
    
    func setConnections(connections: [Int]) {
        self.connections = connections
    }
}
