//
//  JPNetworkError.swift
//  JHTTPHelper
//
//  Created by Jatin Patel on 10/5/23.
//

import Foundation


public struct JPNetworkError : Error
{
    public let reason: String?
    public let httpStatusCode: Int?
    public let requestUrl: URL?
    public let requestBody: String?
    public let serverResponse: String?

    public init(withServerResponse response: Data? = nil, forRequestUrl url: URL, withHttpBody body: Data? = nil, errorMessage message: String, forStatusCode statusCode: Int)
    {
        self.serverResponse = response != nil ? String(data: response!, encoding: .utf8) : nil
        self.requestUrl = url
        self.requestBody = body != nil ? String(data: body!, encoding: .utf8) : nil
        self.httpStatusCode = statusCode
        self.reason = message
    }
}
