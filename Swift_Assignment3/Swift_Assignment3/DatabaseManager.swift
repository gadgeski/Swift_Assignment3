//
//  DatabaseManager.swift
//  Swift_Assignment3
//
//  Created by Dev Tech on 2025/08/02.
//

import SQLite3
import Foundation

struct User {
    let id: Int
    let name: String
    let email: String
    let age: Int
}

class DatabaseManager {
    var db: OpaquePointer?
    
    init(dbPath: String) {
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("データベースに正常に接続しました")
        } else {
            print("データベース接続に失敗しました")
        }
    }
    
    func createTable() {
        let createTableSQL = """
            CREATE TABLE IF NOT EXISTS Users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                age INTEGER
            );
        """
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) == SQLITE_OK {
            print("Usersテーブルを作成しました")
        } else {
            print("テーブル作成に失敗しました")
        }
    }
    
    func insertUser(name: String, email: String, age: Int) -> Bool {
        let insertSQL = "INSERT INTO Users (name, email, age) VALUES (?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, name, -1, nil)
            sqlite3_bind_text(statement, 2, email, -1, nil)
            sqlite3_bind_int(statement, 3, Int32(age))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("ユーザー '\(name)' を正常に挿入しました")
                sqlite3_finalize(statement)
                return true
            }
        }
        
        print("ユーザーの挿入に失敗しました")
        sqlite3_finalize(statement)
        return false
    }
    
    deinit {
        sqlite3_close(db)
    }
}
