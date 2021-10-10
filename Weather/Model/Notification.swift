//
//  Notification.swift
//  Weather
//
//  Created by ADMIMN on 10.10.2021.
//

import Foundation
import UserNotifications


class Notification{
    
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    private func privacyRegister(){
        notificationCenter.requestAuthorization(options: [.alert,.sound, .badge]) { (granted, error) in
            
            guard granted else { return }
            self.notificationCenter.getNotificationSettings { (settings) in
                print(settings)
                guard settings.authorizationStatus == .authorized else { return }
            }
        }
    }
    
    
    func sendNotifications(hour: Int, minute: Int, complitionHandler: @escaping(_: Bool) -> ()){
        DispatchQueue.main.async {
            WeatherManager.getNotificationData(complitionHandler: { [self] weatherData in
                if weatherData != nil{
                    
                    privacyRegister()
                    let content = UNMutableNotificationContent()
                    
                    content.title = "Погода"
                    content.body = "Сейчас \(weatherData!.main.temp) градусов, скорость ветра \(weatherData!.wind.speed) м/с, атмосферное давление \(String(describing: weatherData?.main.pressure)). Приятного дня )"
                    content.sound = UNNotificationSound.default
                    
                    let component = DateComponents(timeZone: TimeZone(identifier: "ru"), hour: hour, minute: minute)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: true)
                    let request = UNNotificationRequest(identifier: "notification\(Int.random(in: 0...99999999999999))", content: content, trigger: trigger)
                    
                    print(trigger)
                    print(component)
                    notificationCenter.add(request) { (error) in
                        if error != nil{
                            complitionHandler(true)
                        }else{
                            complitionHandler(false)
                        }
                    }
                    
                }else{
                    complitionHandler(false)
                }
            })
        }
    }
}
