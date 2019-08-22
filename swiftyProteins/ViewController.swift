import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    let context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkTouchIdAvailable()
    }

    func checkTouchIdAvailable() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            loginButton.isHidden = false
        } else {
            print(error)
            loginButton.isHidden = true
        }
    }
    
    @IBAction func authWithTouchID(_ sender: Any) {
        self.context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate with Touch ID") {
            (success, error) in
                if success {
                    print("Success")
                } else {
                    self.authenticationError("Touch ID Authentication Failed")
                }
        }
    }
    
    func authenticationError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
