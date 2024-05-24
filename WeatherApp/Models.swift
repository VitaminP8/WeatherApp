import Foundation

//подписываем протоколом Codable для функции decode()
class Weather: Codable {
    var id: Int = 0
    var main: String = ""
    var description: String = ""
    var icon: String = ""
}

class Main: Codable {
    var temp: Double = 0.0
    var feels_like: Double = 0.0
    var pressure: Int = 0
    var humidity: Int = 0
}

class Wind: Codable {
    var speed: Double = 0.0
}

//погодные данные получаемые с API
class WeatherData: Codable {
    var weather: [Weather] = []
    var main: Main = Main()
    var wind: Wind = Wind()
    var name: String = ""
}
