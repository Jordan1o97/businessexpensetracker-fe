//
//  ClientService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct Client: Codable, Identifiable {
    let id: String
    let name: String
    let emailAddress: String?
    let officePhone: String?
    let mobilePhone: String?
    let addressLine1: String?
    let addressLine2: String?
    let city: String?
    let stateOrProvince: String?
    let postalCode: String?
    let country: String?
}

class ClientService {
    func fetchClientsByUserId(userId: String, authToken: String, completion: @escaping (Result<[Client], NetworkServiceError>) -> Void) {
        let clientsUrl = URL(string: "\(baseUrlString)/clients/user/\(userId)")!

        print(clientsUrl)

        let headers = [
            "Authorization": "\(authToken)"
        ]

        var clientsRequest = URLRequest(url: clientsUrl)
        clientsRequest.allHTTPHeaderFields = headers

        let clientsTask = URLSession.shared.dataTask(with: clientsRequest) { (data, response, error) in
            if let error = error {
                print("Clients task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Clients task HTTP response status code: \(httpResponse.statusCode)")
                completion(.failure(.dataError))
                return
            }
            if let data = data {
                do {
                    let decodedClients = try JSONDecoder().decode([Client].self, from: data)
                    print("Fetched clients: \(decodedClients)")
                    completion(.success(decodedClients))
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    print("Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                    completion(.failure(.dataError))
                }
            } else {
                print("No clients data")
                completion(.failure(.dataError))
            }
        }
        clientsTask.resume()
    }
    
    func createClient(client: Client, authToken: String, completion: @escaping (Result<Client, Error>) -> Void) {
        let urlString = "\(baseUrlString)/clients"

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
            request.httpBody = try encoder.encode(client)
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
                let createdClient = try JSONDecoder().decode(Client.self, from: data)
                completion(.success(createdClient))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func saveClient(client: Client, authToken: String, completion: @escaping (Result<Client, Error>) -> Void) {
        let urlString = "\(baseUrlString)/clients"

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
            request.httpBody = try encoder.encode(client)
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
                let createdClient = try JSONDecoder().decode(Client.self, from: data)
                completion(.success(createdClient))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchClientById(clientId: String, authToken: String, completion: @escaping (Result<Client, Error>) -> Void) {
        let urlString = "\(baseUrlString)/clients/\(clientId)"
        
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
                let client = try decoder.decode(Client.self, from: data)
                completion(.success(client))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
