import UIKit

class ProteinCell: UITableViewCell {
    @IBOutlet weak var ligand: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            contentView.backgroundColor = UIColor(red: 0.3216, green: 0.7686, blue: 0.6784, alpha: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.contentView.backgroundColor = .white
            }
        }
    }
}


class ProteinListViewController: UIViewController {
    @IBOutlet weak var proteinTableView: UITableView!
    @IBOutlet weak var proteinSearchBar: UISearchBar!
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    var ligandsList = [String]()
    var searchLigands = [String]()
    
    var isSearching = false
    
    var parseAtom = ParseAtom()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        proteinSearchBar.backgroundColor = UIColor(red: 0.3216, green: 0.7686, blue: 0.6784, alpha: 1)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: activityIndicator), animated: true)
        activityIndicator.color = .black
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVc = segue.destination as? ProteinViewController {
            nextVc.atomList = self.parseAtom.atomList
        }
    }
    
    func proteinDataRequest(completeonClosure: @escaping (Data?) -> ()) {
        let url = URL(string: "https://files.rcsb.org/ligands/view//\(self.parseAtom.ligandName)_ideal.pdb")
        let request = NSMutableURLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    self.loadingError("Loading Error")
                    self.activityIndicator.stopAnimating()
                }
                else if let err = error {
                    print(err)
                    self.loadingError("Loading Error")
                    self.activityIndicator.stopAnimating()
                }
                else if (data != nil) {
                    completeonClosure(data as Data?)
                }
            }
        }
        task.resume()
    }
    
    func loadingError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ProteinListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchLigands.count
        } else {
            return ligandsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProteinCell") as! ProteinCell
        
        if isSearching {
            cell.ligand.text = searchLigands[indexPath.row]
        } else {
            cell.ligand.text = ligandsList[indexPath.row]
        }
        cell.layer.borderWidth = 0.1
        cell.layer.cornerRadius = 3
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        
        if !parseAtom.atomList.isEmpty {
            parseAtom.atomList.removeAll()
        }
        if isSearching {
            self.parseAtom.ligandName = self.searchLigands[indexPath.row]
        }
        else {
            self.parseAtom.ligandName = self.ligandsList[indexPath.row]
        }
        self.proteinDataRequest() {
            data in
            self.parseAtom.atomSplit(data: data)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "Ligand", sender: self)
            }
        }
    }
}

extension ProteinListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLigands = ligandsList.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        isSearching = true
        proteinTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        proteinSearchBar.text = ""
        proteinTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ProteinListViewController {
    func startActivityIndicator() {
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
