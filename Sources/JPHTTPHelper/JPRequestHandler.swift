//
//  JPRequest.swift
//  JHTTPHelper
//
//  Created by Jatin Patel on 10/4/23.
//

import Foundation

public protocol JPRequestHandlerProtocol {
    var url:URL {get set}
    var httpMethod :JPHttpMethods {get set}
}

public struct JPRequest:JPRequestHandlerProtocol {
    public var url: URL
    public var httpMethod: JPHttpMethods
    public var requestBody: Data?
    
    public init(url: URL, httpMethod: JPHttpMethods, requestBody: Data? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.requestBody = requestBody ?? nil
    }
}

public struct JPMultiPartRequest : JPRequestHandlerProtocol {

    public var url: URL
    public var httpMethod: JPHttpMethods
    public var request : Encodable

    public init(withUrl url: URL, forHttpMethod method: JPHttpMethods, requestBody: Encodable) {
        self.url = url
        self.httpMethod = method
        self.request = requestBody
    }
}
