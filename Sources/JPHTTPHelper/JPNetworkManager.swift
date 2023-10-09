//
//  JPNetworkManager.swift
//  JHTTPHelper
//
//  Created by Jatin Patel on 9/29/23.
//

import Foundation


public enum JPHttpMethods : String
{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol NetworkManagerPublicDelegate {
    func makeRequest<T:Codable>(request: JPRequest, resultType:T.Type, completionHandler:@escaping (Result<T?, JPNetworkError>) -> Void )
}


internal protocol NetworkManagerDelegate:NetworkManagerPublicDelegate {
    
    func request<T:Codable>(request: JPRequest, resultType:T.Type, completionHandler:@escaping (Result<T?, JPNetworkError>) -> Void )
}

public class JPNetworkManager:NetworkManagerDelegate {
  
    public static let shared = JPNetworkManager()
    
    private init(){
        
    }
    
    public func makeRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler: @escaping (Result<T?, JPNetworkError>) -> Void){
        self.request(request: request, resultType: resultType, completionHandler: completionHandler)
    }
    
    internal func request<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler: @escaping (Result<T?, JPNetworkError>) -> Void) {
        
        switch request.httpMethod {
        case .get:
            getRequest(request: request, resultType: resultType, completionHandler: completionHandler)
            break
        case .post:
            postRequest(request: request, resultType: resultType, completionHandler: completionHandler)
        default:
            break
        }
        
    }
    
    // MARK: - GET REQUEST
    
    private func getRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.get.rawValue
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
    // MARK: - POST REQUEST
    private func postRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.get.rawValue
        request.httpBody = request.httpBody
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
    // MARK: - PUT REQUEST
    private func putRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.put.rawValue
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
    // MARK: - DELETE REQUEST
    private func deleteRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.delete.rawValue
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
    // MARK: - POST MULTIPART REQUEST
    
    private func postMultiPartFormData<T:Codable>(request: JPMultiPartRequest, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void)
    {
        let boundary = "-----------------------------\(UUID().uuidString)"
        let lineBreak = "\r\n"
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = JPHttpMethods.post.rawValue
        urlRequest.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var postBody = Data()

        let requestDictionary = request.request.convertToDictionary()
        if(requestDictionary != nil)
        {
            requestDictionary?.forEach({ (key, value) in
                if(value != nil) {
                    let strValue = value.map { String(describing: $0) }
                    if(strValue != nil && strValue?.count != 0) {
                        postBody.append("--\(boundary + lineBreak)" .data(using: .utf8)!)
                        postBody.append("Content-Disposition: form-data; name=\"\(key)\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
                        postBody.append("\(strValue! + lineBreak)".data(using: .utf8)!)
                    }
                }
            })

            // TODO: Next release
//            if(huRequest.media != nil) {
//                huRequest.media?.forEach({ (media) in
//                    postBody.append("--\(boundary + lineBreak)" .data(using: .utf8)!)
//                    postBody.append("Content-Disposition: form-data; name=\"\(media.parameterName)\"; filename=\"\(media.fileName)\" \(lineBreak + lineBreak)" .data(using: .utf8)!)
//                    postBody.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)" .data(using: .utf8)!)
//                    postBody.append(media.data)
//                    postBody.append(lineBreak .data(using: .utf8)!)
//                })
//            }
            
            postBody.append("--\(boundary)--\(lineBreak)" .data(using: .utf8)!)

            urlRequest.addValue("\(postBody.count)", forHTTPHeaderField: "Content-Length")
            urlRequest.httpBody = postBody

            
            self.performRequest(request: urlRequest, resultType: T.self, completionHandler: completionHandler)
        }
    }
    
    
    // MARK: - PERFORM DATA TASK WITH REQUEST
    
    private func performRequest<T: Codable>(request: URLRequest , resultType:T.Type, completionHandler: @escaping (Result<T?,JPNetworkError>) -> Void)  {
        
        
        URLSession.shared.dataTask(with: request) { (data, httpResponse, error) in
            
            let statusCode = (httpResponse as? HTTPURLResponse)?.statusCode
            
            if(error == nil && data != nil && data?.count != 0) {
                
                do {
                    let parsing = try JSONDecoder().decode(resultType, from: data!)
                    
                    completionHandler(.success(parsing))
                    
                } catch {
                    return completionHandler(.failure(JPNetworkError(withServerResponse: data, forRequestUrl: request.url!, withHttpBody: request.httpBody, errorMessage: "error while decoding JSON response =>\(error.localizedDescription)", forStatusCode: statusCode!)))
                    
                }
                
            } else {
                let networkError = JPNetworkError(withServerResponse: data, forRequestUrl: request.url!, withHttpBody: request.httpBody, errorMessage: error.debugDescription, forStatusCode: statusCode!)
                completionHandler(.failure(networkError))
                
            }
            
        }.resume()
        
    }
    
    
}
