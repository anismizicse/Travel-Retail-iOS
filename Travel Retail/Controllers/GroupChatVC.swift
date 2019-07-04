//
//  GroupChatVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 6/25/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import Firebase

class GroupChatVC: UIViewController {
    
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var attachFileBtn: UIButton!
    @IBOutlet weak var msgText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    var rootRef: DatabaseReference!
    var groupNameRef: DatabaseReference!
    var groupUnseenRef: DatabaseReference!
    var userStateRef: DatabaseReference!
    
    var messageSenderName = ""
    var messageSenderID = ""
    var messageSenderToken = ""
    
    let chatGroup = UserDefaults.standard.string(forKey: Utils.CHAT_GROUP) ?? ""
    var currentUserID = ""
    
    var usersOnlineStatus = [String:String]()
    
    var messagesList = [Messages]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = chatGroup
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "CustomMessagesCell", bundle: nil), forCellReuseIdentifier: "CustomMessagesCell")
        tableView.register(UINib(nibName: "CustomImageMessage", bundle: nil), forCellReuseIdentifier: "CustomImageMessage")
        
        
        let user = Auth.auth().currentUser
        currentUserID = user?.uid ?? ""
        
        rootRef = Database.database().reference()
        userStateRef = rootRef.child("userState")
        groupNameRef = rootRef.child("Groups").child(chatGroup)
        groupUnseenRef = rootRef.child("Groups Unread")
        
        fetchUsersState()
        fetchMessages()
        
        updateUserStatus("true")
        
    }
    
    func fetchUsersState(){
        
        userStateRef.observe(.childAdded, with: { (snapshot) -> Void in
            
            let id = snapshot.key
            
            
            if(id == self.currentUserID){
                
                self.messageSenderID = id
                
                if (snapshot.hasChild("device_token")) {
                    self.messageSenderToken = (snapshot.childSnapshot(forPath: "device_token").value as? String) ?? ""
                }
                
            }else if (snapshot.hasChild("device_token")) {
                
                //Log.d(TAG, "Inside else If ");
                
                
                var deviceToken = (snapshot.childSnapshot(forPath: "device_token").value as? String) ?? ""
                
                var groupChatOpen = (snapshot.childSnapshot(forPath: "groupChatOpen").value as? String) ?? ""
                

                if (groupChatOpen == "false") {
                    self.usersOnlineStatus[id] = deviceToken
                    //usersOnlineStatus.put(uid, deviceToken);
                } else if (groupChatOpen == "true") {
                    
                    self.usersOnlineStatus.removeValue(forKey: id)
                    //usersOnlineStatus.remove(uid);
                }
                
                
            }
            
            if (snapshot.hasChild("thumbnail")) {
                
                
                var thumbnail = (snapshot.childSnapshot(forPath: "thumbnail").value as? String) ?? ""
                
                LiveChatUtil.usersThumbnail[id] = thumbnail
            }
            
        
        })
        
    }
    
    func fetchMessages(){
        groupNameRef.observe(.childAdded, with: { (snapshot) -> Void in
            
            if (snapshot.exists()) {
                
                if let msgDictionary = snapshot.value as? [String: AnyObject] {
                    
                    let message = Messages()
                    message.setValuesForKeys(msgDictionary)
                    self.messagesList.append(message)
                    
                    let indexPath = IndexPath(row: self.messagesList.count-1, section: 0)
                    
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                    
                    //print(message.name,message.uid)
                    
                }
                
            }
            
        })
    }
    
    func updateUserStatus(_ value: String){
        
        let chatOpen = ["groupChatOpen": value ]
    
        userStateRef.updateChildValues([currentUserID: chatOpen])
    
    }
    
    @IBAction func sendImogiMsg(_ sender: UIButton) {
        
    }
    
    @IBAction func attachFile(_ sender: UIButton) {
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if msgText.text != "" {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            
            let datetime = formatter.string(from: Date())
            
            guard let messageKey = groupNameRef.childByAutoId().key else { return }
            
            let chatName = UserDefaults.standard.string(forKey: LiveChatUtil.CHAT_NAME) ?? ""
            let photoUrl = UserDefaults.standard.string(forKey: LiveChatUtil.PHOTO_URL) ?? ""
            let message = msgText.text ?? ""
            
            let messageInfo = [
                "name" : chatName,
                "uid" : currentUserID,
                "message" : message,
                "type" : "text",
                "date": datetime,
                "photo": photoUrl
                ]
            
            groupNameRef.updateChildValues([messageKey: messageInfo])
            
        }
        
    }
}

extension GroupChatVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageData = messagesList[indexPath.row]
        
        //print("Inside tableRow \(userData)")
        var cell = UITableViewCell()
        
        if messageData.type == "text"{
            
            let textCell = tableView.dequeueReusableCell(withIdentifier: "CustomMessagesCell", for: indexPath) as! CustomMessagesCell
            
            textCell.receiverName.text = messageData.name
            textCell.receiverMessage.text = messageData.message
            textCell.receiverMessage.numberOfLines = 0
            
            textCell.senderBox.isHidden = true
            
            
            return textCell
            
            
        }else if messageData.type == "image" || messageData.type == "audio" || messageData.type == "file"{
            
            let imageCell = tableView.dequeueReusableCell(withIdentifier: "CustomImageMessage", for: indexPath) as! CustomImageMessage
            
            
            return imageCell
            
        }
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MembersListCell") as! MembersListCell
        
        //cell.membersListCell(memberCellData: userData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let messageData = messagesList[indexPath.row]
        print("\(messageData.name)")
        
        /*let alertVc = alertService.priceListDetailsAlert()
         alertVc.productInfo = product
         present(alertVc,animated: true)*/
        
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
}
