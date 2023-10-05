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

internal class JPNetworkManager:NetworkManagerDelegate {
  
    public static let shared = JPNetworkManager()
    
    private init(){
        
    }
    
    func makeRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler: @escaping (Result<T?, JPNetworkError>) -> Void){
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
    
    private func getRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.get.rawValue
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
    private func postRequest<T:Codable>(request: JPRequest, resultType: T.Type, completionHandler:@escaping(Result<T?, JPNetworkError>)-> Void){
        
        var request = URLRequest(url: request.url)
        request.httpMethod = JPHttpMethods.get.rawValue
        request.httpBody = request.httpBody
        
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        self.performRequest(request: request, resultType: T.self, completionHandler: completionHandler)
        
    }
    
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
