//
//  ContentView.swift
//  Swift_Assignment3
//
//  Created by Dev Tech on 2025/08/02.
//

import SwiftUI

struct ContentView: View {
    // 入力フィールド用の状態変数
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var ageText: String = ""
    
    // メッセージ表示用の状態変数
    @State private var message: String = ""
    @State private var showAlert: Bool = false
    
    // DatabaseManagerのインスタンス
    private let dbManager: DatabaseManager
    
    init() {
        // データベースパスを設定してDatabaseManagerを初期化
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let dbPath = documentsPath + "/MyDatabase.sqlite"
        self.dbManager = DatabaseManager(dbPath: dbPath)
        
        // テーブルを作成
        dbManager.createTable()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ユーザーの追加について")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 入力フォーム
                VStack(spacing: 15) {
                    TextField("名前", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("メールアドレス", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("年齢", text: $ageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)
                
                // 登録ボタン
                Button(action: insertUser) {
                    Text("ユーザーを登録")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValidInput() ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!isValidInput())
                .padding(.horizontal)
                
                // クリアボタン
                Button(action: clearFields) {
                    Text("入力をクリア")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // メッセージ表示エリア
                if !message.isEmpty {
                    Text(message)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Swift+SQLite")
            .alert("結果", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(message)
            }
        }
    }
    
    // 入力値の妥当性をチェック
    private func isValidInput() -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !ageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               Int(ageText) != nil &&
               Int(ageText)! > 0
    }
    
    // ユーザー挿入処理
    private func insertUser() {
        // 入力値の検証
        guard let age = Int(ageText), age > 0 else {
            message = "年齢は正の整数で入力してください"
            showAlert = true
            return
        }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // メールアドレスの簡単な形式チェック
        if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            message = "正しいメールアドレスの形式で入力してください"
            showAlert = true
            return
        }
        
        // データベースに挿入
        if dbManager.insertUser(name: trimmedName, email: trimmedEmail, age: age) {
            message = "ユーザー '\(trimmedName)' を正常に登録しました"
            clearFields()
        } else {
            message = "ユーザーの登録に失敗しました"
        }
        showAlert = true
    }
    
    // 入力フィールドをクリア
    private func clearFields() {
        name = ""
        email = ""
        ageText = ""
    }
}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
