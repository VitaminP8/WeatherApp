import UIKit
import CoreLocation

class ViewController: UIViewController {

    let locationManager = CLLocationManager()
    let APIKey = "12bce759eb04a58971f74ae050f651c6"
    var weatherData = WeatherData()
    
    //создаем аутлеты
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cityNameLable: UILabel!
    @IBOutlet weak var weatherDescriptionLable: UILabel!
    @IBOutlet weak var temperatureLable: UILabel!
    @IBOutlet weak var temperatureFeelsLikeLable: UILabel!
    @IBOutlet weak var windSpeedLable: UILabel!
    @IBOutlet weak var pressureLable: UILabel!
    @IBOutlet weak var lookWeatherButton: UIButton!
    @IBOutlet weak var cityTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocationManager()
    }

    //получение геологации
    func startLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //получение погодных данных по геолокации
    func updateWeatherInfoByLocation(latitude: Double, longitude: Double) {
        //! - явная распаковка опционального значение (уверены что тут не nil)
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(APIKey)")!
        //доступ к общему экземпляру URLSession для запросов
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            //проверяем нет ли ошибки
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                //обращаемся к основному потоку
                DispatchQueue.main.async {
                    self.updateView()
                }
            }
            catch {
                print("Error: \(error)")
            }
        }
        //запускаем task
        task.resume()
    }
    
    //действие для кнопки
    @IBAction func lookWeatherButtonTapped(_ sender: UIButton) {
        if var city: String = cityTextField.text, !city.isEmpty {
            updateWeatherInfoByCityName(city)
        }
        else {
            print("Error: City name is empty")
            return
        }
    }
    
    //получение погодных данных по городу
    func updateWeatherInfoByCityName(_ city: String) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(APIKey)")!
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error \(error!)")
                return
            }
            
            do {
                self.weatherData = try JSONDecoder().decode(WeatherData.self, from: data!)
                DispatchQueue.main.async {
                    self.updateView()
                }
            }
            catch {
                print("Error: \(error)")
            }
        }
        task.resume()
    }
    
    //функция обновляющая значения на экране телефона
    func updateView() {
        cityNameLable.text = weatherData.name
        weatherDescriptionLable.text = DataSource.weatherIDs[weatherData.weather[0].id]
        var temperature: Double = weatherData.main.temp - 273
        var temperatureFeelsLike: Double = weatherData.main.feels_like - 273
        temperatureLable.text = String(format: "%.1f", temperature) + "°"
        temperatureFeelsLikeLable.text = String(format: "%.1f", temperatureFeelsLike) + "°"
        //description возвращает строковое представление
        windSpeedLable.text = weatherData.wind.speed.description
        pressureLable.text = weatherData.main.pressure.description
        
        //выбор экрана отображающего погоду
        var iconName: String = weatherData.weather[0].icon
        switch iconName {
        case "01d":
            backgroundImageView.image = UIImage(named: "01d")
        case "02d":
            backgroundImageView.image = UIImage(named: "02d")
        case "03d", "04d", "50d":
            backgroundImageView.image = UIImage(named: "04d")
        case "09d":
            backgroundImageView.image = UIImage(named: "09d")
        case "10d":
            backgroundImageView.image = UIImage(named: "10d")
        case "11d":
            backgroundImageView.image = UIImage(named: "11d")
        case "13d":
            backgroundImageView.image = UIImage(named: "13d")
        case "01n":
            backgroundImageView.image = UIImage(named: "01n")
        case "02n":
            backgroundImageView.image = UIImage(named: "02n")
        case "03n", "04n", "50n":
            backgroundImageView.image = UIImage(named: "04n")
        case "09n":
            backgroundImageView.image = UIImage(named: "09n")
        case "10n":
            backgroundImageView.image = UIImage(named: "10n")
        case "11n":
            backgroundImageView.image = UIImage(named: "11n")
        case "13n":
            backgroundImageView.image = UIImage(named: "13n")
        default:
            backgroundImageView.image = UIImage(named: "02d")
        }
    }
    
}

//расширение ViewController
extension ViewController: CLLocationManagerDelegate {
    //когда обновилась геологация
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            //вызываем функцию получения погодных данных
            updateWeatherInfoByLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
            print("latitude = \(lastLocation.coordinate.latitude), longitude = \(lastLocation.coordinate.longitude)")
            //перестаем обновлять геолокацию
            locationManager.stopUpdatingLocation()
        }
    }
}
