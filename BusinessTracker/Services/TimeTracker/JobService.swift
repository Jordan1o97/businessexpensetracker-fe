//
//  JobService.swift
//  BusinessTracker
//
//  Created by Jordan Davis on 2023-03-18.
//

import Foundation

struct Job: Codable, Identifiable {
    let id: String
    let start: Date
    let end: Date?
    let rate: Double
    let income: Double
    let project: String
    let clientId: String
    let taskId: String
    let notes: String
    let userId: String
}

class JobService {
    
    func fetchFilteredJobsAndClients(userId: String, authToken: String, selectedFilter: Int, completion: @escaping (Result<([(String, [Job])], [String: String]), NetworkServiceError>) -> Void) {
        
        let endpoint: String
        switch selectedFilter {
        case 0:
            endpoint = "/jobs/user/\(userId)/daily"
        case 1:
            endpoint = "/jobs/user/\(userId)/monthly"
        case 2:
            endpoint = "/jobs/user/\(userId)/yearly"
        case 3:
            endpoint = "/jobs/user/\(userId)/projects"
        case 4:
            endpoint = "/jobs/user/\(userId)/clients"
        default:
            return
        }
        
        let jobsUrl = URL(string: "\(baseUrlString)\(endpoint)")!
        let clientsUrl = URL(string: "\(baseUrlString)/clients/user/\(userId)")!

        print(jobsUrl)
        print(clientsUrl)

        let group = DispatchGroup()

        var fetchedGroupedJobs: [(String, [Job])] = []
        var fetchedClientNames: [String: String] = [:]

        let headers = [
            "Authorization": "\(authToken)"
        ]

        var jobsRequest = URLRequest(url: jobsUrl)
        jobsRequest.allHTTPHeaderFields = headers

        var clientsRequest = URLRequest(url: clientsUrl)
        clientsRequest.allHTTPHeaderFields = headers

        group.enter()
        let jobsTask = URLSession.shared.dataTask(with: jobsRequest) { (data, response, error) in
            defer { group.leave() }
            if let error = error {
                print("Jobs task error: \(error.localizedDescription)")
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
                        let decodedJobsDictionary = try decoder.decode([String: [String: [Job]]].self, from: data)
                        fetchedGroupedJobs = decodedJobsDictionary.map { ($0.key, $0.value["jobs"] ?? []) }
                    } else {
                        let decodedJobsDictionary = try decoder.decode([String: [Job]].self, from: data)
                        fetchedGroupedJobs = decodedJobsDictionary.map { ($0.key, $0.value) }
                    }
                    print("Fetched grouped jobs: \(fetchedGroupedJobs)")
                } catch {
                    print("Failed to decode grouped jobs: \(error.localizedDescription)")
                }
            }
        }
        jobsTask.resume()

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

        group.notify(queue: .main) {
            if fetchedGroupedJobs.isEmpty || fetchedClientNames.isEmpty {
                completion(.failure(.dataError))
            } else {
                completion(.success((fetchedGroupedJobs, fetchedClientNames)))
            }
        }
    }
    
    func createJob(job: Job, authToken: String, completion: @escaping (Result<Job, Error>) -> Void) {
        let urlString = "\(baseUrlString)/jobs"

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
            request.httpBody = try encoder.encode(job)
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
                let createdJob = try JSONDecoder().decode(Job.self, from: data)
                completion(.success(createdJob))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateJob(job: Job, authToken: String, completion: @escaping (Result<Job, Error>) -> Void) {
        let id = job.id;
        
        let urlString = "\(baseUrlString)/jobs/\(id)"
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
            request.httpBody = try encoder.encode(job)
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
                let updatedJob = try JSONDecoder().decode(Job.self, from: data)
                completion(.success(updatedJob))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
