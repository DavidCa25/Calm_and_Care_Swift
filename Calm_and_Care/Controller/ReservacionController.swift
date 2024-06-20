//
//  ReservacionController.swift
//  Calm_and_Care
//
//  Created by Bryan Montoya on 16/06/24.
//

import UIKit

class ReservacionController: UIViewController {
    var selectedService: String?
    var selectedServiceType: ServiciosController.ServiceType?
    
    @IBOutlet weak var selectedLabel: UILabel!
    
    @IBOutlet weak var datePickerReservacion: UIDatePicker!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedLabel.text = "Servicio seleccionado: \(selectedService ?? "")"
        if let userId = UserDefaults.standard.value(forKey: "userId") as? Int {
            print("ID del usuario encontrado: \(userId)")  // Mensaje de depuración
        } else {
            print("No se encontró el ID del usuario en UserDefaults")
        }
    }
    
    @IBAction func btnReservar(_ sender: UIButton) {
        if let userId = UserDefaults.standard.value(forKey: "userId") as? Int,
           let serviceType = selectedServiceType,
           let service = selectedService {
            let fechaReservacion = formatDate(date: datePickerReservacion.date)
            reservacion(idUsuario: userId, serviceType: serviceType, service: service, fechaReservacion: fechaReservacion)
        } else {
            showAlertError(message: "No se pudo obtener el ID del usuario o del servicio")
        }
    }
    
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    private func reservacion(idUsuario: Int, serviceType: ServiciosController.ServiceType, service: String, fechaReservacion: String) {
        let reservacionEndPoint = "reservacion/addReservacion"
        let getUrlString = APIConfig.baseURL + reservacionEndPoint
        guard var urlComponents = URLComponents(string: getUrlString) else {
            print("URL inválida")
            return
        }
        
        let idTratamiento = getServiceID(serviceType: serviceType, service: service)
        
        urlComponents.queryItems = [
            URLQueryItem(name: "_idUsuario", value: String(idUsuario)),
            URLQueryItem(name: "_idTratamiento", value: String(idTratamiento)),
            URLQueryItem(name: "fechaReservacion", value: fechaReservacion)
        ]
        
        guard let url = urlComponents.url else {
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
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(jsonResponse)
                    }
                } catch let parsingError {
                    print("Error al parsear los datos: \(parsingError)")
                }
            }
        }
        
        task.resume()
    }
    
    private func getServiceID(serviceType: ServiciosController.ServiceType, service: String) -> Int {
        // Aquí deberías tener la lógica para obtener el ID del servicio basado en el tipo de servicio y el nombre
        // Esta es una función de ejemplo, deberías adaptar esto a tu lógica de negocio
        switch serviceType {
        case .manicura:
            return 1
        case .exfoliacion:
            return 2
        case .masaje:
            return 3
        case .pedicura:
            return 4
        }
    }
    
    private func showAlertError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
