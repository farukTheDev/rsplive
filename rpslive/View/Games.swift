//
//  Games.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 23.01.2022.
//

import SwiftUI
import Firebase

struct Games: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    let columns = [
           GridItem(.flexible()),
           GridItem(.flexible())
       ]
    
    //var rooms: [GameRoom] = []
    @State var rooms: [GameRoom] = []
    @State var searchText: String = ""
    @State var newRoomName: String = ""
    @State var showNewRoomDialog: Bool = false
    @State var showCantJoinAlert: Bool = false
    
    var body: some View {
        ZStack {
            Color(.black).ignoresSafeArea()
            VStack {
                /*
                SearchTextField(text: $searchText)
                    .padding()
                 */
                
                if !rooms.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(0...rooms.count - 1, id: \.self) { i in
                                GameRoomView(room: rooms[i]).onTapGesture {
                                    UIDevice.vibrate()
                                    if rooms[i].guest == nil || rooms[i].guest?.id == nil {
                                        self.viewControllerHolder?.present(style: .automatic, transitionStyle: .crossDissolve) {
                                            Play(room: rooms[i])
                                        }
                                    } else {
                                        showCantJoinAlert.toggle()
                                    }
                                }.alert(isPresented: $showCantJoinAlert) {
                                    Alert(title: Text("Can't Join"), message: Text("Room already full."), dismissButton: .default(Text("Ok")))
                                }
                            }
                        }
                    }
                    .padding(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
                } else {
                    Text("There is no games currently going on.")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(64)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
            }
           
            if showNewRoomDialog {
                NewRoomDialog(newRoomName: $newRoomName,
                              showNewRoomDialog: $showNewRoomDialog)
            } else {
                VStack {
                    Spacer()
                    CreateNewRoomButton(showNewRoomDialog: $showNewRoomDialog)
                }
            }
        }.onAppear {
            fetchRooms()
        }
    }
    
    func fetchRooms(){
        let ref = Database.database().reference().child("rooms")
        ref.observe(.value, with: { snapshot in
            rooms.removeAll()
            for case let room as DataSnapshot in snapshot.children {
                let roomDict = room.value! as! Dictionary<String, Any>
                rooms.append(
                    GameRoom(id: roomDict["id"] as? String,
                             title: roomDict["title"]! as! String,
                             host: Gamer(dict: roomDict["host"] as? Dictionary<String, String>)!,
                             hostStatus: roomDict["hostStatus"]! as! Bool,
                             guest: Gamer(dict: roomDict["guest"] as? Dictionary<String, String>) ?? nil,
                             guestStatus: roomDict["guestStatus"]! as! Bool,
                             status: roomDict["status"]! as! Int))
            }
        })
    }
}



struct Games_Previews: PreviewProvider {
    static var previews: some View {
        Games()
    }
}

struct SearchTextField: View {
    
    @Binding var text: String
    
    var body: some View {
        TextField("search rooms by name", text: $text)
            .padding()
            .background(lightGray.opacity(0.5))
            .keyboardType(.emailAddress)
            .cornerRadius(5)
    }
}

struct GameRoomView: View {
    
    var room: GameRoom
    @State var showAnimation = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing).blur(radius: 1.0)
            VStack {
                Text(room.title)
                    .font(.system(size: 18).bold())
                HStack {
                    Image(systemName: "person.fill")
                    Text(room.host.username!)
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }.padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                HStack {
                    Image(systemName: "person.fill")
                    Text(room.guest?.username ?? "Waiting for player")
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }.padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))
                
            }.padding()
            if room.isPrivate {
                Image(systemName: "lock")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(8)
            }
        }
        .cornerRadius(16)
    }
}

struct CreateNewRoomButton: View {
    
    @Binding var showNewRoomDialog: Bool
    
    var body: some View {
        Text("Create New Room")
            .padding()
            .foregroundColor(.orange)
            .background(Color.white)
            .cornerRadius(32)
            .padding(.bottom)
            .onTapGesture {
                showNewRoomDialog.toggle()
            }
    }
}

struct NewRoomDialog: View {
    
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Binding var newRoomName: String
    @Binding var showNewRoomDialog: Bool
    let ref = Database.database().reference()
    
    var body: some View {
        VStack {
            TextField("enter room name", text: $newRoomName)
                .padding()
                .background(lightGray.opacity(0.5))
                .keyboardType(.emailAddress)
                .cornerRadius(5)
                .padding(.top)
            
            Text("Create")
                .padding()
                .foregroundColor(.orange)
                .background(Color.white)
                .cornerRadius(32)
                .padding(.bottom)
                .onTapGesture {
                    let newRoomRef = self.ref.child("rooms").childByAutoId()
                    let me = Gamer(id: Auth.auth().currentUser!.uid,
                                   username: UserDefaults.standard.string(forKey: "username") ?? "user_\(Date().timeIntervalSince1970)")
                    let room = GameRoom(id: newRoomRef.key,
                                        title: newRoomName.isEmpty ? "Untitled Game" : newRoomName,
                                        host: me,
                                        hostStatus: false,
                                        guestStatus: false,
                                        status: 0)
                    
                    ref.child("rooms").child(newRoomRef.key!).setValue(room.toDict())
                    newRoomName = ""
                    showNewRoomDialog.toggle()
                    UIDevice.vibrate()
                    self.viewControllerHolder?.present(style: .automatic, transitionStyle: .crossDissolve) {
                        Play(room: room)
                    }
                }
        }.background(Color.white)
        .cornerRadius(15)
        .padding()
    }
}
