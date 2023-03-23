//
//  TripLogService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct TripLog: Codable, Identifiable {
    let id: String
    let date: Date
    let expense: Double
    let start: Double
    let end: Double
    let rate: Double
    let total: Double
    let vehicle: String
    let origin: String
    let destination: String
    let clientId: String
    let notes: String
}

class TriplogService {
    
    func fetchFilteredTripLogClientsAndVehicles(userId: String, authToken: String, selectedFilter: Int, completion: @escaping (Result<([(String, [TripLog])], [String: String], [String: String]), NetworkServiceError>) -> Void) {
        
        let endpoint: String
        switch selectedFilter {
        case 0:
            endpoint = "/triplog/user/\(userId)/daily"
        case 1:
            endpoint = "/triplog/user/\(userId)/monthly"
        case 2:
            endpoint = "/triplog/user/\(userId)/yearly"
        case 3:
            endpoint = "/triplog/user/\(userId)/vehicles"
        case 4:
            endpoint = "/triplog/user/\(userId)/clients"
        default:
            return
        }
        
        let tripLogsUrl = URL(string: "\(baseUrlString)\(endpoint)")!
        let clientsUrl = URL(string: "\(baseUrlString)/clients/user/\(userId)")!
        let vehiclesUrl = URL(string: "\(baseUrlString)/vehicles/user/\(userId)")!

        print(tripLogsUrl)
        print(clientsUrl)
        print(vehiclesUrl)

        let group = DispatchGroup()

        var fetchedGroupedTripLogs: [(String, [TripLog])] = []
        var fetchedClientNames: [String: String] = [:]
        var fetchedVehicleNames: [String: String] = [:]

        let headers = [
            "Authorization": "\(authToken)"
        ]

        var tripLogsRequest = URLRequest(url: tripLogsUrl)
        tripLogsRequest.allHTTPHeaderFields = headers

        var clientsRequest = URLRequest(url: clientsUrl)
        clientsRequest.allHTTPHeaderFields = headers

        var vehiclesRequest = URLRequest(url: vehiclesUrl)
        vehiclesRequest.allHTTPHeaderFields = headers

        group.enter()
        let tripLogsTask = URLSession.shared.dataTask(with: tripLogsRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("TripLogs task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    if container.decodeNil() {
                        return Date()
                    }
                    let dateString = try container.decode(String.self)
                    print(dateString)
                    
                    if let date = Date.iso8601Formatter.date(from: dateString) {
                        print(date);
                        return date
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                    }
                }

                do {
                    if selectedFilter >= 0 && selectedFilter <= 2 {
                        let decodedTripLogsDictionary = try decoder.decode([String: [String: [TripLog]]].self, from: data)
                        fetchedGroupedTripLogs = decodedTripLogsDictionary.map { ($0.key, $0.value["tripLogs"] ?? []) }
                    } else {
                        let decodedTripLogsDictionary = try decoder.decode([String: [TripLog]].self, from: data)
                        fetchedGroupedTripLogs = decodedTripLogsDictionary.map { ($0.key, $0.value) }
                    }
                    print("Fetched grouped trip logs: \(fetchedGroupedTripLogs)")
                } catch {
                    print("Failed to decode grouped trip logs: \(error.localizedDescription)")
                }
            }
        }
        tripLogsTask.resume()
        group.enter()
        let clientsTask = URLSession.shared.dataTask(with: clientsRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("Clients task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Clients task HTTP response status code: \(httpResponse.statusCode)")
            }
            if let data = data {
                do {
                    let decodedClients = try JSONDecoder().decode([Client].self, from: data)
                    fetchedClientNames = decodedClients.reduce(into: [String: String]()) { result, client in
                        result[client.id] = client.name
                    }
                    print("Fetched clients: \(decodedClients)")
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    print("Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                }
            } else {
                print("No clients data")
            }
        }
        clientsTask.resume()

        group.enter()
        let vehiclesTask = URLSession.shared.dataTask(with: vehiclesRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("Vehicles task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Vehicle task HTTP response status code: \(httpResponse.statusCode)")
            }
            if let data = data {
                do {
                    let decodedVehicles = try JSONDecoder().decode([Vehicle].self, from: data)
                    fetchedVehicleNames = decodedVehicles.reduce(into: [String: String]()) { result, vehicle in
                        result[vehicle.id] = vehicle.name
                    }
                    print("Fetched vehicle names: \(fetchedVehicleNames)")
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    print("Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                }
            }
        }
        vehiclesTask.resume()

        group.notify(queue: .main) {
            completion(.success((fetchedGroupedTripLogs, fetchedClientNames, fetchedVehicleNames)))
        }
    }
    
    func createTripLog(tripLog: TripLog, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(baseUrlString)/triplogs"

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
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(tripLog)
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

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
        }.resume()
    }
    
    func updateTripLog(tripLog: TripLog, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let id = tripLog.id

        let urlString = "\(baseUrlString)/triplogs/\(id)"
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
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(tripLog)
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

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
        }.resume()
    }
}
