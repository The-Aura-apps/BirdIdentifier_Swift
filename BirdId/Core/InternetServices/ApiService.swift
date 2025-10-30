////
////  ApiService.swift
////  BirdId
////
////  Created by ali bakhsha on 8/7/1404 AP.
////
//
//import Foundation
//import Alamofire
//import UIKit
//import Combine
//
//protocol ApiServiceProtocol {
//    
//    func multipartRequest<T: Decodable>(
//        _ url: String,
//        method: HTTPMethod,
//        parameters: [String: Any]?,
//        files: [String: (data: Data, fileName: String, mimeType: String)]?,
//        headers: [String: String]?,
//        expecting: T.Type
//    ) -> AnyPublisher<T, Error>
//
//    func request<T: Decodable>(
//        _ url: String,
//        method: HTTPMethod,
//        body: [String: Any]?,
//        headers: [String: String]?,
//        expecting: T.Type
//    ) -> AnyPublisher<T, Error>
//    
// 
//
//}
//
//
//
//class ApiService: ApiServiceProtocol {
// 
//    private let fileManager = FileManager.default
//
//    
//    
//    
//    func request<T: Decodable>(
//        _ url: String,
//        method: HTTPMethod,
//        body: [String: Any]? = nil,
//        headers: [String: String]? = nil,
//        expecting: T.Type
//    ) -> AnyPublisher<T, Error> {
//        guard let url = URL(string: url) else {
//            return Fail(error: URLError(.badURL))
//                .eraseToAnyPublisher()
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        if let headers = headers {
//            for (key, value) in headers {
//                request.addValue(value, forHTTPHeaderField: key)
//            }
//        }
//
//        if let body = body {
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
//            } catch {
//                return Fail(error: error)
//                    .eraseToAnyPublisher()
//            }
//        }
//
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { output in
//                guard let httpResponse = output.response as? HTTPURLResponse else {
//                    throw APIError.networkError(underlyingError: URLError(.badServerResponse))
//                }
//                guard (200...299).contains(httpResponse.statusCode) else {
//                    throw APIError.httpError(statusCode: httpResponse.statusCode, data: output.data)
//                    
//                }
//                return output.data
//            }
//            .flatMap { data -> AnyPublisher<T, Error> in
//                
////                guard (200...299).contains(data.statusCode) else {
////                    throw APIError.httpError(statusCode: data.statusCode, data: data.data)
////                }
//                
//                if T.self == NoResponse.self {
//                    return Just(NoResponse() as! T)
//                        .setFailureType(to: Error.self)
//                        .eraseToAnyPublisher()
//                } else {
//                    return Just(data)
//                        .decode(type: T.self, decoder: JSONDecoder())
//                        .mapError { APIError.decodingError(underlyingError: $0 as! DecodingError, data: data) }
//                    
//                        .eraseToAnyPublisher()
//                }
//            }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
//    
//    
//    func multipartRequest<T: Decodable>(
//        _ url: String,
//        method: HTTPMethod,
//        parameters: [String: Any]? = nil,
//        files: [String: (data: Data, fileName: String, mimeType: String)]? = nil,
//        headers: [String: String]? = nil,
//        expecting: T.Type
//    ) -> AnyPublisher<T, Error> {
//        Future { promise in
//            guard let url = URL(string: url) else {
//                promise(.failure(URLError(.badURL)))
//                return
//            }
//
//            AF.upload(multipartFormData: { multipartFormData in
//                // Append text parameters
//                parameters?.forEach { key, value in
//                    if let stringValue = value as? String {
//                        multipartFormData.append(Data(stringValue.utf8), withName: key)
//                    }
//                }
//
//                // Append files (can be audio, image, etc.)
//                files?.forEach { key, fileInfo in
//                    multipartFormData.append(fileInfo.data, withName: key, fileName: fileInfo.fileName, mimeType: fileInfo.mimeType)
//                }
//            }, to: url, method: method, headers: HTTPHeaders(headers ?? [:]))
//            .validate()
//            .responseDecodable(of: T.self) { response in
//                switch response.result {
//                case .success(let decodedData):
//                    promise(.success(decodedData))
//                case .failure(let error):
//                    promise(.failure(error))
//                }
//            }
//        }
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//    }
//
//    
//    
//    
//    private func handleDecodingError(_ error: DecodingError) -> Error {
//        switch error {
//        case .dataCorrupted(let context):
//            print("Data corrupted: \(context.debugDescription)")
//            return DecodingError.dataCorrupted(context)
//        case .keyNotFound(let key, let context):
//            print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
//            print("CodingPath: \(context.codingPath)")
//            return DecodingError.keyNotFound(key, context)
//        case .typeMismatch(let type, let context):
//            print("Type '\(type)' mismatch: \(context.debugDescription)")
//            print("CodingPath: \(context.codingPath)")
//            return DecodingError.typeMismatch(type, context)
//        case .valueNotFound(let type, let context):
//            print("Value '\(type)' not found: \(context.debugDescription)")
//            print("CodingPath: \(context.codingPath)")
//            return DecodingError.valueNotFound(type, context)
//        @unknown default:
//            return error
//        }
//    }
//    
//}
//
//
//enum APIError: LocalizedError {
//    case httpError(statusCode: Int, data: Data)
//    case decodingError(underlyingError: DecodingError, data: Data)
//    case networkError(underlyingError: URLError)
//    case unknownError
//
//    // Returns the HTTP status code or a custom error code
//    var errorCode: Int? {
//        switch self {
//        case .httpError(let statusCode, _):
//            return statusCode
//        case .networkError(let underlyingError):
//            return underlyingError.errorCode // URLError provides error codes
//        case .decodingError:
//            return nil // No specific code for decoding errors
//        case .unknownError:
//            return nil // Unknown errors don't have codes
//        }
//    }
//
//    var errorDescription: String? {
//        var description = ""
//
//        if let code = errorCode {
//            description += "Error Code: \(code)\n"
//        }
//
//        switch self {
//        case .httpError(_, let data):
//            description += "\(String(data: data, encoding: .utf8) ?? "No additional information")"
//        case .decodingError(let underlyingError, let data):
//            var details = "Decoding Error: \(underlyingError.localizedDescription)"
//            if let dataString = String(data: data, encoding: .utf8) {
//                details += "\nData being decoded: \(dataString)"
//            }
//            switch underlyingError {
//            case .typeMismatch(let type, let context):
//                details += "\nType mismatch for type \(type): \(context.debugDescription)"
//                details += "\nCoding Path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))"
//            case .valueNotFound(let type, let context):
//                details += "\nValue not found for type \(type): \(context.debugDescription)"
//                details += "\nCoding Path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))"
//            case .keyNotFound(let key, let context):
//                details += "\nKey '\(key.stringValue)' not found: \(context.debugDescription)"
//                details += "\nCoding Path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))"
//            case .dataCorrupted(let context):
//                details += "\nData corrupted: \(context.debugDescription)"
//                details += "\nCoding Path: \(context.codingPath.map(\.stringValue).joined(separator: " -> "))"
//            @unknown default:
//                details += "\nUnknown decoding error occurred."
//            }
//            description += details
//        case .networkError(let underlyingError):
//            description += "Network Error: \(underlyingError.localizedDescription)"
//        case .unknownError:
//            description += "Something went wrong"
//        }
//
//        return description
//    }
//}
//
//struct NoResponse: Decodable { }
