//
//  Register.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 22.01.2022.
//

import SwiftUI
import Firebase

struct Register: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @State var userName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var error: String = ""
    @State var didErrorOccured: Bool = false
    
    @State var db: Firestore!
    

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    self.viewControllerHolder?.dismiss(animated: true, completion: nil)
                }
            VStack {
                VStack {
                    Text("Register")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer().frame(height:48)
                    UserNameTextField(userName: $userName)
                    EmailTextField(email: $email)
                    PasswordTextField(password: $password)
                    
                    Button(action: {
                        UIDevice.vibrate()
                        checkRegisterForm()
                    }, label: {
                        RegisterButton()
                    })
                    
                    if didErrorOccured {
                        ErrorText(error: $error)
                    }
                    
                }.padding(48)
                .background(Color.white)
                .cornerRadius(10)
                .clipped()
            }.padding(48)
            
        }
        .animation(.easeInOut)
    }
    
    func initDB() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    func checkRegisterForm(){
        if !userName.isEmpty {
            if email.isValidEmail() {
                if password.count > 5 {
                    didErrorOccured = false
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            print("\(authResult!.user.email!) created")
                            initDB()
                            UserDefaults.standard.set(userName, forKey: "username")
                            db.collection("users").document(authResult!.user.uid).setData([
                                "email": authResult!.user.email!,
                                "username": userName
                            ]) { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        }
                    }
                } else {
                    didErrorOccured = true
                    error = "Invalid password. Needs to be 6 characters atleast."
                }
            } else {
                didErrorOccured = true
                error = "Invalid email"
            }
        } else {
            didErrorOccured = true
            error = "Invalid username"
        }
    }
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        //Register(isShowing: .constant(true))
        ContentView()
    }
}

struct UserNameTextField: View {
    
    @Binding var userName: String
    
    var body: some View {
        TextField("username", text: $userName)
            .padding()
            .background(lightGray)
            .foregroundColor(.black)
            .keyboardType(.emailAddress)
            .cornerRadius(5)
    }
}

struct EmailTextField: View {
    
    @Binding var email: String
    
    var body: some View {
        TextField("email", text: $email)
            .padding()
            .background(lightGray)
            .foregroundColor(.black)
            .keyboardType(.emailAddress)
            .cornerRadius(5)
    }
}

struct PasswordTextField: View {
    
    @Binding var password: String
    
    var body: some View {
        SecureField("password", text: $password)
            .padding()
            .background(lightGray)
            .foregroundColor(.black)
            .cornerRadius(5)
            .padding(.bottom, 40)
    }
}

struct RegisterButton: View {
    var body: some View {
        Text("REGISTER")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.black)
            .cornerRadius(35)
    }
}

struct ErrorText: View {
    
    @Binding var error: String
    
    var body: some View {
        Spacer().frame(height: 48)
        Text(error)
            .foregroundColor(.red)
    }
}
