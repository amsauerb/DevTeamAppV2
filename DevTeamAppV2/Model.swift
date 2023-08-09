//
//  Model.swift
//  DevTeamApp
//
//  Created by Andrew Sauerbrei on 7/26/23.
//

import Foundation
import PostgresClientKit

class Model {
    
//    static let sharedInstance = Model(environment: Environment, user: String, password: String)
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
        let email: String
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
                
                let text = "SELECT * FROM public.user WHERE username = $1;"
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
                    let email = try columns[6].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
                                          team: team,
                                          role: role,
                                          email: email)
                    
                    userInformation.append(user)
                }
                
                return userInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func createUser(_ username: String, password: String, name: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.user (username, password, name) VALUES ($1, $2, $3) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ username, password, name ])
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
                    let email = try columns[6].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
                                          team: team,
                                          role: role,
                                          email: email)
                    
                    userInformation.append(user)
                }
                
                return userInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateUserPassword(_ username:String, password:String, completion: @escaping (Result<[User], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "UPDATE public.user SET password = $2 WHERE username = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ username, password])
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
                    let email = try columns[6].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
                                          team: team,
                                          role: role,
                                          email: email)
                    
                    userInformation.append(user)
                }
                
                return userInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    struct Video {
        let id: Int
        let title: String
        let filmdate: PostgresDate
        let budgetcomplete: Bool
        let prepredoc: String
        let directorsnotesdoc: String
        let productionnotesdoc: String
        let shotlistdoc: String
        let constructionnotesdoc: String
        let leadproducer: String
        let leaddirector: String
        let needsaddressing: Bool
        let currentstage: String
        let thumbnail: [String]
        let productiontype: String
    }
    
    func videoInformation(_ title: String,
                               completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.video WHERE title = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ title ])
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func videoListByDirectorProducer(_ producer: String, director: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.video WHERE leadproducer = $1 AND leaddirector = $2;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ producer, director ])
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func videoListByProducer(_ producer: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.video WHERE leadproducer = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ producer ])
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func videoListByDirector(_ director: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.video WHERE leaddirector = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ director ])
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func getAllVideos(completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.video;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func createVideo(_ title: String, filmdate: PostgresDate, budgetcomplete: Bool, prepredoc: String, directorsnotesdoc: String, productionnotesdoc: String, shotlistdoc: String, constructionnotesdoc: String, leadproducer: String, leaddirector: String, thumbnail: String, productiontype: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.video (title, filmdate, budgetcomplete, prepredoc, directorsnotesdoc, productionnotesdoc, shotlistdoc, constructionnotesdoc, leadproducer, leaddirector, thumbnail, productiontype) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, ARRAY [$11], $12) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ title, filmdate, budgetcomplete, prepredoc, directorsnotesdoc, productionnotesdoc, shotlistdoc, constructionnotesdoc, leadproducer, leaddirector, thumbnail, productiontype ])
                defer { cursor.close() }
                
                var videoInformation = [Video]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()
                    
                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateVideoFromMasterDocs(_ title: String, budgetcomplete: Bool, currentstage: String, completion: @escaping (Result<[Video], Error>) -> Void) {

        connectionPool.withConnection { connectionResult in

            let result = Result<[Video], Error> {

                let connection = try connectionResult.get()

                let text = "UPDATE public.video SET budgetcomplete = $2, currentstage = $3 WHERE title = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute(parameterValues: [ title, budgetcomplete, currentstage ])
                defer { cursor.close() }

                var videoInformation = [Video]()

                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let title = try columns[1].string()
                    let filmdate = try columns[2].date()
                    let budgetcomplete = try columns[3].bool()
                    let prepredoc = try columns[4].string()
                    let directorsnotesdoc = try columns[5].string()
                    let productionnotesdoc = try columns[6].string()
                    let shotlistdoc = try columns[7].string()
                    let constructionnotesdoc = try columns[8].string()
                    let leadproducer = try columns[9].string()
                    let leaddirector = try columns[10].string()
                    let needsaddressing = try columns[11].bool()
                    let currentstage = try columns[12].string()
                    let thumbnail = try [columns[13].string()]
                    let productiontype = try columns[14].string()

                    let video = Video(id: id,
                                          title: title,
                                          filmdate: filmdate,
                                      budgetcomplete: budgetcomplete,
                                      prepredoc: prepredoc,
                                      directorsnotesdoc: directorsnotesdoc,
                                      productionnotesdoc: productionnotesdoc,
                                      shotlistdoc: shotlistdoc,
                                      constructionnotesdoc: constructionnotesdoc,
                                      leadproducer: leadproducer,
                                          leaddirector: leaddirector,
                                      needsaddressing: needsaddressing,
                                      currentstage: currentstage,
                                      thumbnail: thumbnail,
                                      productiontype: productiontype)

                    videoInformation.append(video)
                }

                return videoInformation
            }

            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
}
