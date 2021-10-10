//
//  WeatherManager.swift
//  Weather
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4613cd0a7687f546d96c96617b02cd4c&units=metric&lang=ru"
    let userDefualts = UserDefaults()
    var delegate: WeatherManagerDelegate?
    
    static func getNotificationData(complitionHandler: @escaping(_ weatherData: WeatherData?) -> ()) {
        DispatchQueue.main.async{
            let userDefualts = UserDefaults()
            let url = userDefualts.string(forKey: "url")
            
            guard ((url != nil) && url?.replacingOccurrences(of: " ", with: "") != "") else {
                complitionHandler(nil)
                return
            }
            
            var request = URLRequest(url: URL(string: userDefualts.string(forKey: "url")!)!)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    complitionHandler(nil)
                    return
                }
                complitionHandler(try? JSONDecoder().decode(WeatherData.self, from: data))
            }
            task.resume()
        }
    }
    
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        userDefualts.set(urlString, forKey: "url")
        
        performRequest(urlString: urlString)
    }
    
    
    func fetchWeather(latitude: CLLocationDegrees, lonitute: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(lonitute)"
        userDefualts.set(urlString, forKey: "url")
        
        performRequest(urlString: urlString)
    }
    
    
    func performRequest(urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task =  session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let pressure = decodedData.main.pressure
            let speed = decodedData.wind.speed
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, pressure: pressure, weatherSpeed: speed)
            return weather
            
            
        } catch {
            print("error")
            return nil
        }
    }
    
}
