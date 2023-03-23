//
//  CategoryService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct Category: Codable {
    let name: String
    let icon: String
    let id: String
}

class CategoryService {
    func fetchCategoriesByUserId(userId: String, authToken: String, completion: @escaping (Result<[Category], NetworkServiceError>) -> Void) {
        let categoriesUrl = URL(string: "\(baseUrlString)/categories/user/\(userId)")!
        
        print(categoriesUrl)
        
        let headers = [
            "Authorization": "\(authToken)"
        ]
        
        var categoriesRequest = URLRequest(url: categoriesUrl)
        categoriesRequest.allHTTPHeaderFields = headers
        
        let categoriesTask = URLSession.shared.dataTask(with: categoriesRequest) { (data, response, error) in
            if let error = error {
                print("Categories task error: \(error.localizedDescription)")
                completion(.failure(.dataError))
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Categories task HTTP response status code: \(httpResponse.statusCode)")
                completion(.failure(.dataError))
                return
            }
            if let data = data {
                do {
                    let decodedCategories = try JSONDecoder().decode([Category].self, from: data)
                    print("Fetched categories: \(decodedCategories)")
                    completion(.success(decodedCategories))
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    print("Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                    completion(.failure(.dataError))
                }
            } else {
                print("No categories data")
                completion(.failure(.dataError))
            }
        }
        categoriesTask.resume()
    }
    
    func createCategory(category: Category, authToken: String, completion: @escaping (Result<Category, Error>) -> Void) {
        let urlString = "\(baseUrlString)/categories"

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
            request.httpBody = try encoder.encode(category)
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
                let createdCategory = try JSONDecoder().decode(Category.self, from: data)
                completion(.success(createdCategory))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func saveCategory(category: Category, authToken: String, completion: @escaping (Result<Category, Error>) -> Void) {
        let urlString = "\(baseUrlString)/categories"

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
            request.httpBody = try encoder.encode(category)
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
                let createdCategory = try JSONDecoder().decode(Category.self, from: data)
                completion(.success(createdCategory))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCategoryById(categoryId: String, authToken: String, completion: @escaping (Result<Category, Error>) -> Void) {
        let urlString = "\(baseUrlString)/categories/\(categoryId)"
        
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
                let category = try decoder.decode(Category.self, from: data)
                completion(.success(category))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}

