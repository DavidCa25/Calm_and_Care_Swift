import UIKit

class loginController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtContraseña: UITextField!
    
    // Propiedad para almacenar el nombre de usuario y contraseña recibidos del servidor
 

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard let username = txtUsername.text, !username.isEmpty else {
            showAlertError(message: "Ingresa tu nombre de usuario")
            return
        }
        guard let contraseña = txtContraseña.text, !contraseña.isEmpty else {
            showAlertError(message: "Ingresa tu contraseña")
            return
        }
        validarCredenciales(username, contraseña)
    }
    
    private func validarCredenciales(_ username: String, _ contraseña: String) {
        let loginEndPoint = "user/login?usuario=\(username)&contraseña=\(contraseña)"
        let getUrlString = APIConfig.baseURL + loginEndPoint
        guard let url = URL(string: getUrlString) else {
            print("URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
                request.httpMethod = "POST"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error en la petición: \(error)")
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        print("Respuesta del servidor inválida")
                        return
                    }
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let userId = jsonResponse["idUsuario"] as? Int {
                                // Guardar el ID del usuario en UserDefaults
                                UserDefaults.standard.set(userId, forKey: "userId")
                                
                                print(jsonResponse)
                                print(userId)
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "perfilView", sender: self)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.showAlertError(message: "Datos de usuario inválidos")
                                }
                            }
                        } catch let parsingError {
                            print("Error al parsear los datos \(parsingError)")
                        }
                    }
                }
                
                task.resume()
            }
    
    
    
    private func showAlertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Verifica si ya hay una alerta presentada
        if self.presentedViewController == nil {
            self.present(alert, animated: true)
        }
    }
}
