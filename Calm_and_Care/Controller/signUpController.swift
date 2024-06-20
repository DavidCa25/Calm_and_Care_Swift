//
//  signUpController.swift
//  Calm_and_Care
//
//  Created by Bryan Montoya on 16/06/24.
//

import UIKit

class signUpController: UIViewController {

    @IBOutlet weak var txtUsuario: UITextField!
    
    @IBOutlet weak var txtContraseña: UITextField!
    
    @IBOutlet weak var txtNombre: UITextField!
    
    @IBOutlet weak var txtApellido: UITextField!
    
    @IBOutlet weak var txtCorreo: UITextField!
    
    @IBOutlet weak var txtEdad: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func btnSignUp(_ sender: UIButton) {
        
        guard let username = txtUsuario.text, !username.isEmpty else{
            showAlertError(message: "Usuario incorrecto")
            return
        }
        guard let contraseña = txtContraseña.text , !contraseña.isEmpty else{
            showAlertError(message: "Contraseña incorrecta")
            return
        }
        guard let nombre = txtNombre.text, !nombre.isEmpty else{
            showAlertError(message: "Nombre incorrecto")
            return
        }
        guard let apellido = txtApellido.text , !apellido.isEmpty else{
            showAlertError(message: "Apellido incorrecto")
            return
        }
        guard let correo = txtCorreo.text , !correo.isEmpty else{
            showAlertError(message: "Correo incorrecto")
            return
        }
        guard let edadText = txtEdad.text ,
              let edadInt = Int(edadText), edadInt >= 0,
              !edadText.isEmpty else{
            showAlertError(message: "Edad incorrecta")
            return
        }
        
        
        
        registrar(username, contraseña, nombre, apellido, correo, edadInt)
        
    }
    private func registrar(
        _ username: String,
        _ contraseña: String,
        _ nombre: String,
        _ apellido: String,
        _ correo: String,
        _ edad: Int
    ){
        
        
        
        let signUpEndPoint = "user/signUp?usuario=\(username)&nombre=\(nombre)&apellido=\(apellido)&edad=\(edad)&correo=\(correo)&contraseña=\(contraseña)"
        let getUrlString = APIConfig.baseURL + signUpEndPoint
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
}
