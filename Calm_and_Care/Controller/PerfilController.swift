//
//  PerfilController.swift
//  Calm_and_Care
//
//  Created by Bryan Montoya on 16/06/24.
//

import UIKit

class PerfilController: UIViewController {
    
    
    @IBOutlet weak var txtNombre: UILabel!
    
    @IBOutlet weak var lblUsuario: UILabel!
    
    @IBOutlet weak var lblEdad: UILabel!
    
    @IBOutlet weak var lblCorreo: UILabel!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
          
            if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
                getUserById(userId)
            } else {
                print("No se encontró el ID del usuario en UserDefaults")
            }
        }
        
        private func getUserById(_ idUsuario: Int) {
            let getUserEndPoint = "user/getUser?idUsuario=\(idUsuario)"
            let getUrlString = APIConfig.baseURL + getUserEndPoint
            guard let url = URL(string: getUrlString) else {
                print("URL Invalida")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error en la petición: \(error)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    print("Respuesta del servidor invalida")
                    return
                }
                if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async {
                                self.updateUIWithUserData(jsonResponse)
                            }
                        }
                    } catch let parsingError {
                        print("Error al parsear los datos \(parsingError)")
                    }
                }
            }
            
            task.resume()
        }
        
        private func updateUIWithUserData(_ userData: [String: Any]) {
            if let nombre = userData["nombre"] as? String {
                txtNombre.text = nombre
            }
            if let usuario = userData["usuario"] as? String {
                lblUsuario.text = usuario
            }
            if let edad = userData["edad"] as? Int {
                lblEdad.text = String(edad)
            }
            if let correo = userData["correo"] as? String {
                lblCorreo.text = correo
            }
        }
    }
