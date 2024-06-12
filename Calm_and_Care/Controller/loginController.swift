//
//  loginController.swift
//  Calm_and_Care
//
//  Created by ISSC_611_2024 on 10/06/24.
//

import UIKit

class loginController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    
    @IBOutlet weak var txtContraseña: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func btnLogin(_ sender: Any) {
        guard let username = txtUsername.text, !username.isEmpty else{
            showAlertCorrect(message: "Usuario incorrecto")
            return
        }
        guard let contraseña = txtContraseña.text , !contraseña.isEmpty else{
            showAlertError(message: "Contraseña incorrecta")
            return
        }
        
    }
    private func validarCredenciales(_ username: String, _ contraseña: String){
        
        let loginEndPoint = "user/validarLogin?user=\(username)&password=\(contraseña)"
        let getUrlString = APIConfig.baseURL + loginEndPoint
        guard let url = URL(string: getUrlString) else {
            print("Url Invalida")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            if let error = error {
                print("Error en la peticion: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...999).contains(httpResponse.statusCode) else {
                print("Respuesta del servidor invalida")
                return
            }
            if let data = data {
                do{
                    if let jsonReponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(jsonReponse)
                    }
                }catch let parsingError {
                    print("Error al parsear los datos \(parsingError)")
                }
            }
        }
        
        task.resume()
        
        
    }

    private func showAlertError(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    private func showAlertCorrect(message: String){
        let alert = UIAlertController(title: "Correct", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


    
    
