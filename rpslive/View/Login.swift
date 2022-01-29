//
//  Login.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 21.01.2022.
//

import SwiftUI
import Firebase

let orange = Color(red: 1, green: 0.49, blue: 0.43)
let purple = Color(red: 0.18, green: 0.23, blue: 0.56)
let lightGray = Color(red: 0.98, green: 0.98, blue: 0.98)

struct Login: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @State var loginEmail: String = ""
    @State var loginPassword: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack {
                GreetingText()
                LoginEmailTextField(email: $loginEmail)
                LoginPasswordTextField(password: $loginPassword)
                
                Button(action: {
                    UIDevice.vibrate()
                    Auth.auth().signIn(withEmail: loginEmail, password: loginPassword, completion: { authResult, error in
                        if error == nil {
                            let settings = FirestoreSettings()
                            Firestore.firestore().settings = settings
                            let db = Firestore.firestore()
                            db.collection("users").document(authResult!.user.uid).getDocument(completion: {(document, error) in
                                if error == nil {
                                    UserDefaults.standard.set(document?.get("username"), forKey: "username")
                                }
                            })
                            self.viewControllerHolder?.present(style: .fullScreen, transitionStyle: .crossDissolve) {
                                Games()
                            }
                        } else {
                            print("Error: \(error!)")
                        }
                    })
                }, label: {
                    LoginButton()
                })
                
                Spacer()
                        .frame(height: 30)
                
                Button(action: {
                    UIDevice.vibrate()
                    self.viewControllerHolder?.present(style: .overCurrentContext, transitionStyle: .crossDissolve) {
                                    Register()
                                }
                }, label: {
                    NotAMemberButton()
                })
            }.padding()
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
            .previewDevice(PreviewDevice(rawValue: "iPhone XR"))
    }
}

struct GreetingText: View {
    var body: some View {
        Text("Login")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 40)
    }
}

struct LoginButton: View {
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.black)
            .cornerRadius(35)
    }
}

struct LoginEmailTextField: View {
    
    @Binding var email: String
    
    var body: some View {
        TextField("email", text: $email)
            .padding()
            .background(lightGray)
            .keyboardType(.emailAddress)
            .cornerRadius(5)
    }
}

struct LoginPasswordTextField: View {
    
    @Binding var password: String
    
    var body: some View {
        SecureField("password", text: $password)
            .padding()
            .background(lightGray)
            .cornerRadius(5)
            .padding(.bottom, 40)
    }
}

struct NotAMemberButton: View {
    var body: some View {
        Text("Not a member? Join now.")
            .font(.none)
            .foregroundColor(.black)
            .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

