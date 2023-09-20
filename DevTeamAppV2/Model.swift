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
        
//        let result = testConnection()
//
//        if !result {
//            connectionConfiguration.host = environment.hostTwo
//
//            connectionPool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration,
//                                            connectionConfiguration: connectionConfiguration)
//        }
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
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func userByID(_ id: Int,
                               completion: @escaping (Result<[User], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.user WHERE id = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ id ])
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.user;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func userByName(_ name: String,
                               completion: @escaping (Result<[User], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.user WHERE name = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ name ])
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func createUser(_ username: String, password: String, name: String, email: String, role: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.user (username, password, name, email, role, tasklist) VALUES ($1, $2, $3, $4, $5, ARRAY [$6]) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ username, password, name, email, role ])
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func updateUserInformation(_ username: String, name: String, email: String, role: String, completion: @escaping (Result<[User], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "UPDATE public.user SET name = $2, email = $3, role = $4 WHERE username = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ username, name, email, role])
                defer { cursor.close() }
                
                var userInformation = [User]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let username = try columns[1].string()
                    let password = try columns[2].string()
                    let name = try columns[3].string()
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
    
    func deleteUser(_ username: String, completion: @escaping (Result<[User], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[User], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "DELETE FROM public.user WHERE username = $1 RETURNING *;"
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
                    let role = try columns[4].string()
                    let email = try columns[5].string()
                    
                    let user = User(id: id,
                                          username: username,
                                          password: password,
                                          name: name,
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
        let postdate: PostgresDate
        let startdate: PostgresDate
        let frameworkdate: PostgresDate
        let macrodate: PostgresDate
        let microdate: PostgresDate
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func createVideo(_ title: String, filmdate: PostgresDate, budgetcomplete: Bool, prepredoc: String, directorsnotesdoc: String, productionnotesdoc: String, shotlistdoc: String, constructionnotesdoc: String, leadproducer: String, leaddirector: String, thumbnail: String, productiontype: String, postdate: PostgresDate, startdate: PostgresDate, frameworkdate: PostgresDate, macrodate: PostgresDate, microdate: PostgresDate, completion: @escaping (Result<[Video], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.video (title, filmdate, budgetcomplete, prepredoc, directorsnotesdoc, productionnotesdoc, shotlistdoc, constructionnotesdoc, leadproducer, leaddirector, thumbnail, productiontype, postdate, startdate, frameworkdate, macrodate, microdate) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, ARRAY [$11], $12, $13, $14, $15, $16, $17) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ title, filmdate, budgetcomplete, prepredoc, directorsnotesdoc, productionnotesdoc, shotlistdoc, constructionnotesdoc, leadproducer, leaddirector, thumbnail, productiontype, postdate, startdate, frameworkdate, macrodate, microdate ])
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateVideoDates(_ title: String, filmdate: PostgresDate, postdate: PostgresDate, frameworkdate: PostgresDate, macrodate: PostgresDate, microdate: PostgresDate, completion: @escaping (Result<[Video], Error>) -> Void) {

        connectionPool.withConnection { connectionResult in

            let result = Result<[Video], Error> {

                let connection = try connectionResult.get()

                let text = "UPDATE public.video SET filmdate = $2, postdate = $3, frameworkdate = $4, macrodate = $5, microdate = $6 WHERE title = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute(parameterValues: [ title, filmdate, postdate, frameworkdate, macrodate, microdate ])
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }

                return videoInformation
            }

            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updatePostDate(_ title: String, postdate: PostgresDate, completion: @escaping (Result<[Video], Error>) -> Void) {

        connectionPool.withConnection { connectionResult in

            let result = Result<[Video], Error> {

                let connection = try connectionResult.get()

                let text = "UPDATE public.video SET postdate = $2 WHERE title = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute(parameterValues: [ title, postdate ])
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }

                return videoInformation
            }

            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateVideoFromMasterDocs(_ id: Int, title: String, budgetcomplete: Bool, currentstage: String, director: String, producer: String, filmdate: PostgresDate, postdate: PostgresDate, macrodate: PostgresDate, microdate: PostgresDate, frameworkdate: PostgresDate, completion: @escaping (Result<[Video], Error>) -> Void) {

        connectionPool.withConnection { connectionResult in

            let result = Result<[Video], Error> {

                let connection = try connectionResult.get()

                let text = "UPDATE public.video SET title = $2, budgetcomplete = $3, currentstage = $4, leaddirector = $5, leadproducer = $6, filmdate = $7, postdate = $8, macrodate = $9, microdate = $10, frameworkdate = $11 WHERE id = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }

                let cursor = try statement.execute(parameterValues: [ id, title, budgetcomplete, currentstage, director, producer, filmdate, postdate, macrodate, microdate, frameworkdate ])
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }

                return videoInformation
            }

            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func deleteVideo(_ title: String, completion: @escaping (Result<[Video], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Video], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "DELETE FROM public.video WHERE title = $1 RETURNING *;"
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
                    let postdate = try columns[15].date()
                    let startdate = try columns[16].date()
                    let frameworkdate = try columns[17].date()
                    let macrodate = try columns[18].date()
                    let microdate = try columns[19].date()
                    
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
                                      productiontype: productiontype,
                                      postdate: postdate,
                                      startdate: startdate,
                                      frameworkdate: frameworkdate,
                                      macrodate: macrodate,
                                      microdate: microdate)
                    
                    videoInformation.append(video)
                }
                
                return videoInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    struct Task {
        let tid: Int
        let title: String
        let description: String
        let deadline: PostgresDate
    }
    
    func taskInformation(_ tid: Int, completion: @escaping (Result<[Task], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Task], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.task WHERE tid = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid ])
                defer { cursor.close() }
                
                var taskInformation = [Task]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let title = try columns[1].string()
                    let description = try columns[2].string()
                    let deadline = try columns[3].date()

                    let task = Task(tid: tid,
                                          title: title,
                                          description: description,
                                          deadline: deadline)

                    taskInformation.append(task)
                }
                
                return taskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func getAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Task], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.task;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute()
                defer { cursor.close() }
                
                var taskInformation = [Task]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let title = try columns[1].string()
                    let description = try columns[2].string()
                    let deadline = try columns[3].date()

                    let task = Task(tid: tid,
                                          title: title,
                                          description: description,
                                          deadline: deadline)

                    taskInformation.append(task)
                }
                
                return taskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func addTask(_ title: String, description: String, deadline: PostgresDate, completion: @escaping (Result<[Task], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Task], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.task (title, description, deadline) VALUES ($1, $2, $3) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ title, description, deadline ])
                defer { cursor.close() }
                
                var taskInformation = [Task]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let title = try columns[1].string()
                    let description = try columns[2].string()
                    let deadline = try columns[3].date()

                    let task = Task(tid: tid,
                                          title: title,
                                          description: description,
                                          deadline: deadline)

                    taskInformation.append(task)
                }
                
                return taskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateTask(_ tid: Int, title: String, description: String, deadline: PostgresDate, completion: @escaping (Result<[Task], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Task], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "UPDATE public.task SET title = $2, description = $3, deadline = $4 WHERE tid = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid, title, description, deadline ])
                defer { cursor.close() }
                
                var taskInformation = [Task]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let title = try columns[1].string()
                    let description = try columns[2].string()
                    let deadline = try columns[3].date()

                    let task = Task(tid: tid,
                                          title: title,
                                          description: description,
                                          deadline: deadline)

                    taskInformation.append(task)
                }
                
                return taskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func deleteTask(_ tid: Int, completion: @escaping (Result<[Task], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Task], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "DELETE FROM public.task WHERE tid = $1 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid ])
                defer { cursor.close() }
                
                var taskInformation = [Task]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let title = try columns[1].string()
                    let description = try columns[2].string()
                    let deadline = try columns[3].date()

                    let task = Task(tid: tid,
                                          title: title,
                                          description: description,
                                          deadline: deadline)

                    taskInformation.append(task)
                }
                
                return taskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    struct UserTask {
        let id: Int
        let tid: Int
    }
    
    func addUserTask(_ tid: Int, id: Int, completion: @escaping (Result<[UserTask], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[UserTask], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "INSERT INTO public.user_task (tid, id) VALUES ($1, $2) RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid, id ])
                defer { cursor.close() }
                
                var usertaskInformation = [UserTask]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let id = try columns[1].int()

                    let usertask = UserTask(id: id,
                                            tid: tid)

                    usertaskInformation.append(usertask)
                }
                
                return usertaskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func getAllTasksForUID(_ id: Int, completion: @escaping (Result<[UserTask], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[UserTask], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.user_task WHERE id = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ id ])
                defer { cursor.close() }
                
                var usertaskInformation = [UserTask]()

                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let tid = try columns[1].int()

                    let usertask = UserTask(id: id,
                                    tid: tid)

                    usertaskInformation.append(usertask)
                }
                
                return usertaskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func getAllUsersForTID(_ tid: Int, completion: @escaping (Result<[UserTask], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[UserTask], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT * FROM public.user_task WHERE tid = $1;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid ])
                defer { cursor.close() }
                
                var usertaskInformation = [UserTask]()

                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let tid = try columns[1].int()

                    let usertask = UserTask(id: id,
                                    tid: tid)

                    usertaskInformation.append(usertask)
                }
                
                return usertaskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func deleteUserTask(_ tid: Int, id: Int, completion: @escaping (Result<[UserTask], Error>) -> Void) {
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[UserTask], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "DELETE FROM public.user_task WHERE tid = $1 AND id = $2 RETURNING *;"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ tid, id ])
                defer { cursor.close() }
                
                var usertaskInformation = [UserTask]()

                for row in cursor {
                    let columns = try row.get().columns
                    let tid = try columns[0].int()
                    let id = try columns[1].int()

                    let usertask = UserTask(id: id,
                                            tid: tid)

                    usertaskInformation.append(usertask)
                }
                
                return usertaskInformation
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
}
