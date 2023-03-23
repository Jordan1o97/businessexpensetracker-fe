//
//  Vehicle.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct Vehicle: Codable, Identifiable {
    let id: String
    let name: String
}

class VehicleService {
    func fetchVehiclesByUserId(userId: String, authToken: String, completion: @escaping (Result<[Vehicle], NetworkServiceError>) -> Void) {
        let vehiclesUrl = URL(string: "\(baseUrlString)/vehicles/user/\(userId)")!
        
        print(vehiclesUrl)
        
        let headers = [
            "Authorization": "\(authToken)"
        ]
        
        var vehiclesRequest = URLRequest(url: vehiclesUrl)
        vehiclesRequest.allHTTPHeaderFields = headers
        
        let vehiclesTask = URLSession.shared.dataTask(with: vehiclesRequest) { (data, response, error) in
            if let error = error {
                print("Vehicles task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Vehicles task HTTP response status code: \(httpResponse.statusCode)")
                completion(.failure(.dataError))
                return
            }
            if let data = data {
                do {
                    let decodedVehicles = try JSONDecoder().decode([Vehicle].self, from: data)
                    print("Fetched vehicles: \(decodedVehicles)")
                    completion(.success(decodedVehicles))
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    print("Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                    completion(.failure(.dataError))
                }
            } else {
                print("No vehicles data")
                completion(.failure(.dataError))
            }
        }
        vehiclesTask.resume()
    }
    
    func createVehicle(vehicle: Vehicle, authToken: String, completion: @escaping (Result<Vehicle, Error>) -> Void) {
        let urlString = "\(baseUrlString)/vehicles"

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(vehicle)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }

            if let data = data {
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }

            do {
                let createdVehicle = try JSONDecoder().decode(Vehicle.self, from: data)
                completion(.success(createdVehicle))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func saveVehicle(vehicle: Vehicle, authToken: String, completion: @escaping (Result<Vehicle, Error>) -> Void) {
        let urlString = "\(baseUrlString)/vehicles"

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(vehicle)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }

            if let data = data {
                if let responseBody = String(data: data, encoding: .utf8) {
                    print("Response body: \(responseBody)")
                }
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }

            do {
                let createdVehicle = try JSONDecoder().decode(Vehicle.self, from: data)
                completion(.success(createdVehicle))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchVehicleById(vehicleId: String, authToken: String, completion: @escaping (Result<Vehicle, Error>) -> Void) {
        let urlString = "\(baseUrlString)/vehicles/\(vehicleId)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(authToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let vehicle = try decoder.decode(Vehicle.self, from: data)
                completion(.success(vehicle))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
