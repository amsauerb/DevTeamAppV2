//
//  Model.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import Foundation
import PostgresClientKit

class Model {
    
    //
    // MARK: Model and connection lifecycle
    //
    
    init(environment: Environment, user: String, password: String) {
        
        // Configure a connection pool with, at most, a single connection.  Using a connection pool
        // allows the connection to be lazily created, automatically re-creates the connection if
        // there is an unrecoverable error, and performs database operations on a background thread.
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 1
        
        // Configure how connections are created in that connection pool.
        var connectionConfiguration = ConnectionConfiguration()
        connectionConfiguration.host = environment.host
        connectionConfiguration.port = environment.port
        connectionConfiguration.ssl = environment.ssl
        connectionConfiguration.database = environment.database
        connectionConfiguration.user = user
        connectionConfiguration.credential = .scramSHA256(password: password)
        
        connectionPool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration,
                                        connectionConfiguration: connectionConfiguration)
    }
    
    /// A pool of (at most) a single connection.
    var connectionPool: ConnectionPool
    
    /// Closes any existing connection to the Postgres server.
    func disconnect() {
        
        // Close the current connection pool
        connectionPool.close()
        
        // And create a new one.  Its connection will be lazily created.
        connectionPool = ConnectionPool(
            connectionPoolConfiguration: connectionPool.connectionPoolConfiguration,
            connectionConfiguration: connectionPool.connectionConfiguration)
    }
    
    
    //
    // MARK: Entities and operations
    //
    
    /// A record of the user information for a given username.
    struct User {
        let id: Int
        let username: String
        let password: String
        let name: String
        let team: String
        let role: String
    }
    
    /// Gets the user record for the specified username
    ///
    /// - Parameters:
    ///   - username: the username
    ///   - completion: a completion handler, invoked with either the user record or an error.
    func userInformation(_ username: String,
                               completion: @escaping (Result<[User], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT id, username, password, name, team, role FROM public.user WHERE username = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ username ])
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let team = try columns[4].string()
                    let role = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
                                          team: team,
                                          role: role)
                    
                    userInformation.append(user)
                }
                
                return userInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
}
