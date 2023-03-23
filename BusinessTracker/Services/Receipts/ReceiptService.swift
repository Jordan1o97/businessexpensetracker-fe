//
//  ReceiptService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation
import Combine

struct Receipt: Codable, Identifiable {
    let id: String
    let category: String
    let date: Date
    let initalTotal: Double
    let tax: Double
    let tip: Double
    let clientId: String
    let paymentMode: String
    let description: String
    let status: String?
}


class ReceiptService {
    func createReceipt(receipt: Receipt, authToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseUrlString)/receipts"
        
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
            request.httpBody = try encoder.encode(receipt)
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
            
            completion(.success(()))
        }.resume()
    }
    
    func updateReceipt(receipt: Receipt, authToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let id = receipt.id
        
        let urlString = "\(baseUrlString)/receipts/\(id)"
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
            request.httpBody = try encoder.encode(receipt)
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
            
            completion(.success(()))
        }.resume()
    }
    
    func fetchFilteredReceiptClientsAndCategories(userId: String, authToken: String, selectedFilter: Int, completion: @escaping (Result<([(String, [Receipt])], [String: String], [String: String]), NetworkServiceError>) -> Void) {
        
        let endpoint: String
        switch selectedFilter {
        case 0:
            endpoint = "/receipts/user/\(userId)/daily"
        case 1:
            endpoint = "/receipts/user/\(userId)/monthly"
        case 2:
            endpoint = "/receipts/user/\(userId)/yearly"
        case 3:
            endpoint = "/receipts/user/\(userId)/category"
        case 4:
            endpoint = "/receipts/user/\(userId)/client"
        default:
            return
        }
        
        let receiptsUrl = URL(string: "\(baseUrlString)\(endpoint)")!
        let clientsUrl = URL(string: "\(baseUrlString)/clients/user/\(userId)")!
        let categoriesUrl = URL(string: "\(baseUrlString)/categories/user/\(userId)")!
        
        print(receiptsUrl)
        print(clientsUrl)
        print(categoriesUrl)
        
        let group = DispatchGroup()
        
        var fetchedGroupedReceipts: [(String, [Receipt])] = []
        var fetchedClientNames: [String: String] = [:]
        var fetchedCategoryNames: [String: String] = [:]
        
        let headers = [
            "Authorization": "\(authToken)"
        ]
        
        var receiptsRequest = URLRequest(url: receiptsUrl)
        receiptsRequest.allHTTPHeaderFields = headers
        
        var clientsRequest = URLRequest(url: clientsUrl)
        clientsRequest.allHTTPHeaderFields = headers
        
        var categoriesRequest = URLRequest(url: categoriesUrl)
        categoriesRequest.allHTTPHeaderFields = headers
        
        group.enter()
        let receiptsTask = URLSession.shared.dataTask(with: receiptsRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("Receipts task error: \(error.localizedDescription)")
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
                        print(date)
                        return date
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                    }
                }
                
                do {
                    let decodedReceiptsDictionary = try decoder.decode([String: [Receipt]].self, from: data)
                    fetchedGroupedReceipts = decodedReceiptsDictionary.map { ($0.key, $0.value) }
                    print("Fetched grouped receipts: \(fetchedGroupedReceipts)")
                } catch {
                    print("Failed to decode grouped receipts: \(error.localizedDescription)")
                }
            }
        }
        receiptsTask.resume()
        
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
        let categoriesTask = URLSession.shared.dataTask(with: categoriesRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("Categories task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let data = data {
                do {
                    let decodedCategories = try JSONDecoder().decode([Category].self, from: data)
                    fetchedCategoryNames = decodedCategories.reduce(into: [String: String]()) { (result, category) in
                        result[category.id] = category.name
                    }
                    print("Fetched category names: \(fetchedCategoryNames)")
                } catch {
                    print("Failed to decode category names: \(error.localizedDescription)")
                }
            }
        }
        categoriesTask.resume()
        
        group.notify(queue: .main) {
            if fetchedGroupedReceipts.isEmpty || fetchedClientNames.isEmpty || fetchedCategoryNames.isEmpty {
                completion(.failure(.dataError))
            } else {
                completion(.success((fetchedGroupedReceipts, fetchedClientNames, fetchedCategoryNames)))
            }
        }
    }
    
    func fetchTotalReceiptsByUserId(userId: String, authToken: String, completion: @escaping (Result<Double, Error>) -> Void) {
        let urlString = "\(baseUrlString)/receipts/user/\(userId)/total"

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
                let responseObject = try decoder.decode([String: Double].self, from: data)
                if let total = responseObject["total"] {
                    completion(.success(total))
                } else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func fetchReceiptsPDF(userId: String, authToken: String) -> AnyPublisher<Data, Error> {
        let url = URL(string: "\(baseUrlString)/receipts/user/\(userId)/category/pdf")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("\(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/pdf", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("fetchReceiptsPDF: Failed to cast response as HTTPURLResponse")
                    throw URLError(.badServerResponse)
                }
                if httpResponse.statusCode == 200 {
                    print("fetchReceiptsPDF: Received 200 && Data: \(httpResponse.statusCode)")
                    return data
                } else {
                    print("fetchReceiptsPDF: Received non-200 status code: \(httpResponse.statusCode)")
                    throw URLError(.badServerResponse)
                }
            }
            .mapError { error in
                print("fetchReceiptsPDF: Error occurred during network request: \(error)")
                return error
            }
            .eraseToAnyPublisher()
    }

}
