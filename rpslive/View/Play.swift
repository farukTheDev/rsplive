//
//  Play.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 26.01.2022.
//

import SwiftUI
import Firebase

struct Play: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var room: GameRoom
    var weapons = ["Rock", "Scissors", "Paper"]
    
    @State var isHost: Bool = false
    @State var selectedWeapon: String = ""
    @State var hostSelection: String = ""
    @State var guestSelection: String = ""
    @State var isReady: Bool = false
    @State var actionText: String = "Ready ?"
    @State var willShowResult: Bool = false
    @State var isCurrentlyPreparing: Bool = false
    @State var willBeDismissed = false
    
    var body: some View {
        ZStack {
            Color(.orange).ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Text("Connected:")
                            .foregroundColor(.white)
                        Image(systemName: room.guest?.id != nil ? "checkmark" : "square")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Text("Ready:")
                            .foregroundColor(.white)
                        if isHost {
                            Image(systemName: room.guestStatus ? "checkmark" : "square")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: room.hostStatus ? "checkmark" : "square")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text((isHost ? (room.guest == nil ? "Waiting for opponent" : (room.guest!.username == nil ? "Waiting for opponent" : room.guest!.username )) : room.host.username)!)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .padding()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .top)
                .ignoresSafeArea()
                if !isReady {
                    Button(action: {
                        getReady()
                    }, label: {
                        GoButton()
                    })
                }
                VStack {
                    HStack {
                        Text("Connected:")
                            .foregroundColor(.white)
                        Image(systemName: room.guest?.id != nil ? "checkmark" : "square")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    HStack {
                        Text("Ready:")
                            .foregroundColor(.white)
                        if isHost {
                            Image(systemName: room.guestStatus ? "checkmark" : "square")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: room.hostStatus ? "checkmark" : "square")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    if isReady {
                        HStack {
                            Button(action: {
                                selectedWeapon = "Rock"
                            }, label: {
                                WeaponView(selectedWeapon: selectedWeapon ,
                                           text: "Rock",
                                           image: "rock")
                            })
                            
                            Button(action: {
                                selectedWeapon = "Scissors"
                            }, label: {
                                WeaponView(selectedWeapon: selectedWeapon ,
                                           text: "Scissors",
                                           image: "scissors")
                            })
                            
                            Button(action: {
                                selectedWeapon = "Paper"
                            }, label: {
                                WeaponView(selectedWeapon: selectedWeapon ,
                                           text: "Paper",
                                           image: "paper")
                            })
                            
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .top)
                .background(Color.black)
                .ignoresSafeArea()
            }
            if willShowResult {
                VStack {
                    Text(gameResult(hostSelection: hostSelection, guestSelection: guestSelection)).font(.title).padding()
                    HStack {
                        VStack {
                            Text(room.host.username ?? "")
                            Image(hostSelection.lowercased()).frame(width: 100, height: 100).scaledToFill()
                        }.padding()
                        VStack {
                            Text(room.guest?.username ?? "")
                            Image(guestSelection.lowercased()).frame(width: 100, height: 100).scaledToFit()
                        }.padding()
                        
                    }
                    Button(action: {
                        resetRoom()
                    }, label: {
                        Text("Again ?")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 220, height: 60)
                            .background(Color.black)
                            .cornerRadius(35)
                    }).padding()
                    
                }
                .padding()
                .background(lightGray)
                .cornerRadius(10)
            }
        }.onAppear {
            print(room.id!)
            let ref = Database.database()
                .reference().child("rooms").child(room.id!)
            if room.host.id == Auth.auth().currentUser!.uid {
                isHost = true
            } else {
                room.guest = Gamer(id: Auth.auth().currentUser!.uid,
                                   username: "Guest User")
                ref.updateChildValues(["guest": Gamer(id: Auth.auth().currentUser!.uid,
                                                      username: UserDefaults.standard.string(forKey: "username")!).toDict()])
            }
            listenRoom()
        }.onDisappear {
            leaveRoom()
        }
        
    }
    
    private func leaveRoom(){
        let ref = Database.database()
            .reference().child("rooms").child(room.id!)
        ref.removeAllObservers()
        if isHost {
            ref.removeValue()
        } else {
            if !willBeDismissed {
                ref.updateChildValues(["guest": nil])
            }
        }
    }
    
    private func resetRoom(){
        isCurrentlyPreparing = true
        getReady()
        actionText = "Ready ?"
        isReady = false
        willShowResult = false
        selectedWeapon = ""
        setWeapon(weapon: "")
    }
    
    private func gameResult(hostSelection: String, guestSelection: String) -> String {
        if hostSelection.isEmpty || guestSelection.isEmpty {
            return ""
        } else {
            if hostSelection == guestSelection {
                return "DRAW!"
            } else {
                if isHost {
                    if hostSelection == "Rock" {
                        if guestSelection == "Scissors" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    } else if hostSelection == "Scissors" {
                        if guestSelection == "Paper" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    } else {
                        if guestSelection == "Rock" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    }
                } else {
                    if guestSelection == "Rock" {
                        if hostSelection == "Scissors" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    } else if guestSelection == "Scissors" {
                        if hostSelection == "Paper" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    } else {
                        if hostSelection == "Rock" {
                            return "YOU WIN!"
                        } else {
                            return "YOU LOSE!"
                        }
                    }
                }
            }
        }
    }
    
    private func getReady(){
        let ref = Database.database()
            .reference().child("rooms").child(room.id!)
        if isHost {
            if room.hostStatus {
                room.hostStatus = false
                ref.updateChildValues(["hostStatus": false])
            } else {
                room.hostStatus = true
                ref.updateChildValues(["hostStatus": true])
            }
        } else {
            if room.guestStatus {
                room.guestStatus = false
                ref.updateChildValues(["guestStatus": false])
            } else {
                room.guestStatus = true
                ref.updateChildValues(["guestStatus": true])
            }
        }
    }
    
    private func listenRoom(){
        let ref = Database.database()
            .reference().child("rooms").child(room.id!)
        ref.observe(.value, with: { snapshot in
           
            let roomDict = snapshot.value as? Dictionary<String, Any>
            if roomDict == nil {
                ref.removeAllObservers()
                willBeDismissed = true
                presentationMode.wrappedValue.dismiss()
            } else {
                room = GameRoom(id: roomDict!["id"] as? String,
                                title: roomDict!["title"] as! String,
                                host: Gamer(dict: roomDict!["host"] as? Dictionary<String, String>)!,
                                hostStatus: roomDict!["hostStatus"]! as! Bool,
                                hostSelection: roomDict!["hostSelection"]! as! String,
                                guest: Gamer(dict: roomDict!["guest"] as? Dictionary<String, String>) ?? nil,
                                guestStatus: roomDict!["guestStatus"]! as! Bool,
                                guestSelection: roomDict!["guestSelection"]! as! String,
                                status: roomDict!["status"]! as! Int)
                
                if room.hostStatus && room.guestStatus && room.hostSelection.isEmpty && room.guestSelection.isEmpty {
                    actionText = "Choose One !"
                    isReady = true
                    delayText()
                }
               
                if !room.hostSelection.isEmpty && !room.guestSelection.isEmpty && !isCurrentlyPreparing {
                    hostSelection = room.hostSelection
                    guestSelection = room.guestSelection
                    willShowResult = true
                }
                
                if room.hostSelection.isEmpty && room.guestSelection.isEmpty {
                    isCurrentlyPreparing = false
                }
            }
            
        })
        
        if isHost {
            ref.onDisconnectRemoveValue()
        } else {
            room.guestStatus = false
            room.guestSelection = ""
            ref.onDisconnectUpdateChildValues(["guest": nil])
        }
    }
    
    private func setWeapon(weapon: String) {
        let ref = Database.database()
            .reference().child("rooms").child(room.id!)
        if isHost {
            room.hostSelection = weapon
            ref.updateChildValues(["hostSelection": weapon])
        } else {
            room.guestSelection = weapon
            ref.updateChildValues(["guestSelection": weapon])
        }
    }
    
    private func delayText() {
        // Delay of 7.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if selectedWeapon == "" {
                selectedWeapon = weapons.randomElement()!
            }
            setWeapon(weapon: selectedWeapon)
        }
    }
}

struct Play_Previews: PreviewProvider {
    static var previews: some View {
        Play(room: GameRoom(id: "123",
                            title: "",
                            host: Gamer(id: "", username: ""),
                            hostStatus: false,
                            hostSelection: "",
                            guest: Gamer(id: "", username: ""),
                            guestStatus: false,
                            guestSelection: "",
                            status: 0,
                            isPrivate: false))
            .previewDevice(PreviewDevice(rawValue: "iPhone XR"))
    }
}


struct WeaponView: View {
    
    var selectedWeapon: String
    @State var text: String
    @State var image: String
    
    var body: some View {
        VStack {
            //Text(text).foregroundColor(.orange)
            Image(image)
        }
        .frame(width: 96, height: 96)
        .overlay(
            Circle()
                .strokeBorder(selectedWeapon == text ? Color.white : Color.clear, lineWidth: 1)
        )
        .padding()
    }
}

struct GoButton: View {
    var body: some View {
        Text("Go !")
            .font(.headline)
            .foregroundColor(.black)
            .frame(width: 220, height: 60)
            .background(Color.white)
            .cornerRadius(35)
    }
}

struct OpponentText: View {
    var body: some View {
        Text("Waiting for Opponent")
            .font(.title)
            .padding()
            .foregroundColor(.white)
            .frame(height: 120)
    }
}
