//
//  WeatherData.swift
//  Weather
//

import Foundation

struct WeatherData: Codable { //endocable+decodable
    let name:String
    let main:Main
    let weather:[Weather]
    let wind: Wind
}

struct Main: Codable {
    let temp: Double
    let pressure: Double
}

struct Weather:Codable {
    let description:String
    let id:Int
}

struct Wind: Codable{
    let speed: Double
}
