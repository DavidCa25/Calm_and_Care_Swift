import UIKit

class ServiciosController: UIViewController {
    
    @IBOutlet weak var pullDownManicura: UIButton!
    
    @IBOutlet weak var pullDownExfoliacion: UIButton!
    
    @IBOutlet weak var pullDownMasaje: UIButton!
    
    @IBOutlet weak var pullDownPedicura: UIButton!
    
    var pickerData: [String] = []
        var selectedServiceType: ServiceType?
        
        enum ServiceType {
            case manicura, exfoliacion, masaje, pedicura
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configurar los menús
            configureMenu(for: pullDownManicura, serviceType: .manicura)
            configureMenu(for: pullDownExfoliacion, serviceType: .exfoliacion)
            configureMenu(for: pullDownMasaje, serviceType: .masaje)
            configureMenu(for: pullDownPedicura, serviceType: .pedicura)
            
            // Fetch data for each picker
            fetchData(for: .manicura)
            fetchData(for: .exfoliacion)
            fetchData(for: .masaje)
            fetchData(for: .pedicura)
        }
        
        private func configureMenu(for button: UIButton, serviceType: ServiceType) {
            button.showsMenuAsPrimaryAction = true
            button.menu = UIMenu(title: "Cargando...", children: [])
            button.tag = serviceType.hashValue
        }
        
        private func fetchData(for serviceType: ServiceType) {
            let endpoint: String
            switch serviceType {
            case .manicura:
                endpoint = "tratamiento/getTratamientoByManicura"
            case .exfoliacion:
                endpoint = "tratamiento/getTratamientoByExfoliacion"
            case .masaje:
                endpoint = "tratamiento/getTratamientoByMasaje"
            case .pedicura:
                endpoint = "tratamiento/getTratamientoByPedicura"
            }
            
            let urlString = APIConfig.baseURL + endpoint
            guard let url = URL(string: urlString) else {
                print("URL inválida")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                            DispatchQueue.main.async {
                                self?.pickerData = jsonResponse.compactMap { $0["servicio"] as? String }
                                self?.updateMenu(for: serviceType)
                                print(jsonResponse)
                            }
                        }
                    } catch let parsingError {
                        print("Error al parsear los datos: \(parsingError)")
                    }
                }
            }
            task.resume()
        }
        
        private func updateMenu(for serviceType: ServiceType) {
            var menuItems: [UIAction] = []
            for item in pickerData {
                let action = UIAction(title: item, handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    switch serviceType {
                    case .manicura:
                        self.pullDownManicura.setTitle(item, for: .normal)
                    case .exfoliacion:
                        self.pullDownExfoliacion.setTitle(item, for: .normal)
                    case .masaje:
                        self.pullDownMasaje.setTitle(item, for: .normal)
                    case .pedicura:
                        self.pullDownPedicura.setTitle(item, for: .normal)
                    }
                    
                    print("Item seleccionado: \(item)")  // Mensaje de depuración
                    self.navigateToReservation(with: item, for: serviceType)
                })
                menuItems.append(action)
            }
            
            let menu = UIMenu(title: "Seleccione una opción", options: .displayInline, children: menuItems)
            
            switch serviceType {
            case .manicura:
                pullDownManicura.menu = menu
            case .exfoliacion:
                pullDownExfoliacion.menu = menu
            case .masaje:
                pullDownMasaje.menu = menu
            case .pedicura:
                pullDownPedicura.menu = menu
            }
        }
        
        private func navigateToReservation(with service: String, for serviceType: ServiceType) {
            print("Navegando a la reservación con el servicio: \(service)")  // Mensaje de depuración
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Cambia "Main" por el nombre de tu storyboard
            if let reservationVC = storyboard.instantiateViewController(withIdentifier: "ReservacionController") as? ReservacionController {
                reservationVC.selectedService = service
                reservationVC.selectedServiceType = serviceType // Pasar el tipo de servicio
                navigationController?.pushViewController(reservationVC, animated: true)
            } else {
                showAlert(message: "No se pudo encontrar el controlador de reservación")
            }
        }
        
        private func showAlert(message: String) {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
