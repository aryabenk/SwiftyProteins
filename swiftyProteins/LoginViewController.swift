import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var touchIDloginButton: UIButton!
    let context = LAContext()
    var ligands = Ligands()
    
    @IBOutlet weak var faceIDLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        touchIDloginButton.isHidden = true
        faceIDLoginButton.isHidden = true
        checkBiometricalEntry()
    }
    
    func checkBiometricalEntry() {
        var error: NSError?
        let canAuthenticate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if canAuthenticate && context.biometryType == .touchID {
            touchIDloginButton.isHidden = false
        } else if canAuthenticate && context.biometryType == .faceID {
            faceIDLoginButton.isHidden = false
        } else {
            print(error as Any)
            authenticationError("Biometrics are not supported on this device, Sorry.")
        }
    }
    
    @IBAction func authenticationWithFaceId(_ sender: UIButton) {
        self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate Face ID") {
            (success, error) in
            if success {
                self.getLigands()
            } else {
                self.authenticationError("Face ID Authentication Failed")
            }
        }
    }
    
    @IBAction func authenticationWithTouchID(_ sender: Any) {
        self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate with Touch ID") {
            (success, error) in
            if success {
                self.getLigands()
            } else {
                self.authenticationError("Touch ID Authentication Failed")
            }
        }
    }
    
    func authenticationError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func getLigands() {
        ligands.ligandsRequest {
            data in
            if let ligandsData = data as Data? {
                if let ligands = String(data: ligandsData, encoding: .utf8) {
                    for i in ligands.split(separator: "\n") {
                        self.ligands.ligandsList.append(String(i))
                    }
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ProteinList", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextVc = segue.destination as? ProteinListViewController {
            nextVc.ligandsList = ligands.ligandsList
        }
    }
}
