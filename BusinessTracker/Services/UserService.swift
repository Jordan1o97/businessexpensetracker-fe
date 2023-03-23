//
//  UserService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let accountType: String
    let username: String
    let password: String
    let companyName: String
}

enum UserServiceError: Error {
    case emailAlreadyInUse
}


class UserServie {
    
    func getUserById(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = "\(baseUrlString)/users/\(id)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
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
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func signUp(accountType: String, username: String, password: String, name: String, companyName: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlString = "\(baseUrlString)/users"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = User(id: UUID().uuidString, name: name, accountType: accountType, username: username, password: password, companyName: companyName)
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(user)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            if httpResponse.statusCode == 409 {
                completion(.failure(UserServiceError.emailAlreadyInUse))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func signIn(username: String, password: String, completion: @escaping (Result<(token: String, userId: String, accountType: String), Error>) -> Void) {
        let urlString = "\(baseUrlString)/login"

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let credentials = ["username": username, "password": password]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print(response)
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["token"] as? String,
                   let userId = json["userId"] as? String,
                   let accountType = json["accountType"] as? String {
                    completion(.success((token: token, userId: userId, accountType: accountType)))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateUserAccountType(userId: String, authToken: String, accountType: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "\(baseUrlString)/users/\(userId)/\(accountType)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(authToken)", forHTTPHeaderField: "Authorization")
        
        let accountTypeUpdate = ["accountType": accountType]
        
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(accountTypeUpdate)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.decodingError))
                return
            }
            
            do {
                let message = try JSONDecoder().decode(String.self, from: data)
                completion(.success(message))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
}
