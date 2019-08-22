import UIKit

class ParseAtom: NSObject {
    var ligandName = String()
    var atomList: [Atom] = []
    var atomsData: [String] = []
    var CPKColors = [String: UIColor]()
    var colors = [String: UIColor]()
    
    override init() {
        super.init()
        self.createCPKColors()
    }
    
    func UIColorFromRGB(r: UInt, g: UInt, b: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((r & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((g & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(b & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func createCPKColors() {
        CPKColors["H"] = .white
        CPKColors["C"] = .black
        CPKColors["N"] = UIColorFromRGB(r: 34, g: 51, b: 255)
        CPKColors["O"] = .red
        CPKColors["F"] = .green
        CPKColors["Cl"] = .green
        CPKColors["Br"] = UIColorFromRGB(r: 153, g: 34, b: 0)
        CPKColors["I"] = UIColorFromRGB(r: 102, g: 0, b: 187)
        CPKColors["He"] = .cyan
        CPKColors["Ne"] = .cyan
        CPKColors["Ar"] = .cyan
        CPKColors["Xe"] = .cyan
        CPKColors["Kr"] = .cyan
        CPKColors["P"] = .orange
        CPKColors["S"] = .yellow
        CPKColors["B"] = UIColorFromRGB(r: 255, g: 170, b: 119)
        CPKColors["Li"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["Cs"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["Na"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["K"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["Rb"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["Fr"] = UIColorFromRGB(r: 119, g: 0, b: 255)
        CPKColors["Be"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Mg"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Ca"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Sr"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Ba"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Ra"] = UIColorFromRGB(r: 0, g: 199, b: 0)
        CPKColors["Ti"] = .gray
        CPKColors["Fe"] = UIColorFromRGB(r: 221, g: 119, b: 0)
        CPKColors["Other"] = UIColorFromRGB(r: 221, g: 119, b: 255)
        
    }
    
    func CPKColor(symb: String) -> UIColor {
        if let color = CPKColors[symb] {
            return color
        } else {
            return CPKColors["Other"]!
        }
    }
    
    func parseAtomData() {
        for line in atomsData {
            let atomData = line.split(separator: " ")
            
            if atomData[0] == "ATOM" {
                self.atomList.append(
                    Atom(id: Int(atomData[1])!,
                         symb: String(atomData[11]),
                         color: CPKColor(symb: String(atomData[11])),
                         x: Float(atomData[6])!,
                         y: Float(atomData[7])!,
                         z: Float(atomData[8])!
                    )
                )
            }
            else if atomData[0] == "CONECT" {
                var connections: [Int] = []
                
                for index in 1...atomData.count - 1 {
                    connections.append(Int(atomData[index])!)
                }
                self.atomList[Int(atomData[1])! - 1].setConnections(connections: connections)
            }
        }
    }
    
    func atomSplit(data: Data?) {
        if let ligandData = data as Data? {
            if let stringData = String(data: ligandData, encoding: .utf8) {
                for line in stringData.split(separator: "\n") {
                    self.atomsData.append(String(line))
                }
                self.parseAtomData()
            }
        }
        if !self.atomsData.isEmpty {
            self.atomsData.removeAll()
        }
    }
}
