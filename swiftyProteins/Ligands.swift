import UIKit

class Ligands: NSObject {
    var ligandsList: [String] = []
    
    func ligandsRequest(completeonClosure: @escaping (Data?) -> ()) {
        let url = URL(string:"https://projects.intra.42.fr/uploads/document/document/312/ligands.txt")!
        let task = URLSession.shared.dataTask(with:url) { (data, response, error) in
            if let err = error{
                print(err)
            }
            if let res = response as? HTTPURLResponse {
                print(res.statusCode)
                if res.statusCode == 200 {
                    completeonClosure(data as Data?)
                } else {
                    print("Bad status code")
                }
            } else {
                print("Bad response")
            }
        }
        task.resume()
    }
}
