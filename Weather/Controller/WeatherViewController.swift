//
//  ViewController.swift
//  Weather
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController{
    
    @IBOutlet weak var conditionImage: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    let notification = Notification()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        //start updating - updates current location
        
        
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    @IBAction func notficateMe(_ sender: UIButton) {
        let alert = UIAlertController(title: "Напоминать о погоде", message: "Будем напоминать вам о погоде каждый день! Введите время когда вам удобно получать уводмление", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Введите время в формате чч:мм"
        }
        alert.addAction(UIAlertAction(title: "отправить", style: .default, handler: { action in
            let textField = alert.textFields![0]
            
            if textField.hasText{
                let time = textField.text!.split(separator: ":")
                if time.count != 2 {
                    self.present(alert, animated: true)
                    return
                }
                
                let hour = Int(time[0]) ?? -1
                let minute = Int(time[1]) ?? -1
                
                if hour.chekCorrectTime() && minute.chekCorrectTime(){
                    DispatchQueue.main.async {
                        self.notification.sendNotifications(hour: hour, minute: minute) { bool in
                            if bool == true{
                                self.generateLightAlert(title: "Успех", message: "Теперь мы будем напоминать вам о погоде в \(hour):\(minute)")
                            }else{
                                self.generateLightAlert(title: "Ошибка", message: "Попробуйте выбрать другой город!")
                            }
                        }
                    }
                }else{
                    alert.message = "Напишите время в правильном формате и мы будем напоминать вам о погоде каждый день"
                    self.present(alert, animated: true)
                }
            }else{
                alert.message = "Напишите время в правильном формате и мы будем напоминать вам о погоде каждый день"
                self.present(alert, animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "выйти", style: .destructive))
        present(alert, animated: true)
    }
    
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    
    func generateLightAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
}

//MARK: - TextFieldDelegate extension

extension WeatherViewController: UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(textField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }else{
            textField.placeholder = "Type smth"
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //get text and set
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate extension

extension WeatherViewController: WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async {
            self.tempLabel.text = weather.temperatureString
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
        
        // print(weather.temperature)
    }
}

//MARK: - CLLocation delegate
//kad se pozove reqLocation

extension WeatherViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if  let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, lonitute: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
    }
}



