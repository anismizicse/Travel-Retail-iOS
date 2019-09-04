//
//  GroupChatVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 6/25/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import MobileCoreServices

class GroupChatVC: UIViewController {
    
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var attachFileBtn: UIButton!
    @IBOutlet weak var msgText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    let imagePicker = UIImagePickerController()
    
    var rootRef: DatabaseReference!
    var groupNameRef: DatabaseReference!
    var groupUnseenRef: DatabaseReference!
    var userStateRef: DatabaseReference!
    var storageRef: StorageReference!
    
    var messageSenderName = ""
    var messageSenderID = ""
    var messageSenderToken = ""
    
    let chatGroup = UserDefaults.standard.string(forKey: Utils.CHAT_GROUP) ?? ""
    var currentUserID = ""
    
    var usersOnlineStatus = [String:String]()
    
    var messagesList = [Messages]()
    
    let alertService = AlertService()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = chatGroup
        sendMsgBtn.isHidden = true
        
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
        storageRef =  Storage.storage().reference().child("User Files")
        
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
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
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
        
        let alert = UIAlertController(title: "Choose Option",
                                      message: "",
                                      preferredStyle: .alert)
        
        let action1 = UIAlertAction(title: "Images", style: .default, handler: { (action) -> Void in
            
            self.setupImagePicker()
            //print("ACTION 1 selected!")
        })
        
        let action2 = UIAlertAction(title: "Documents", style: .default, handler: { (action) -> Void in
            
            let types: [String] = [kUTTypePDF as String, (kUTTypeAudio as CFString) as String]
            let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
            //print("ACTION 2 selected!")
        })
        
        let action3 = UIAlertAction(title: "Record Audio", style: .default, handler: { (action) -> Void in
            let alertVc = self.alertService.audioRecordAlert()
            self.present(alertVc,animated: true)
        })
        
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        /*// Restyle the view of the Alert
         alert.view.tintColor = UIColor.brown  // change text color of the buttons
         alert.view.backgroundColor = UIColor.cyan  // change background color
         alert.view.layer.cornerRadius = 25   // change corner radius*/
        
        // Add action buttons and present the Alert
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if msgText.text != "" {
            let message = msgText.text ?? ""
            saveMessage(message: message,type: "text")
        }
        
    }
    
    func saveMessage(message: String, type: String){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        
        let datetime = formatter.string(from: Date())
        
        guard let messageKey = groupNameRef.childByAutoId().key else { return }
        
        let chatName = UserDefaults.standard.string(forKey: LiveChatUtil.CHAT_NAME) ?? ""
        let photoUrl = UserDefaults.standard.string(forKey: LiveChatUtil.PHOTO_URL) ?? ""
        
        
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
    
    @IBAction func messageEditingChanged(_ sender: UITextField) {
        
        
        if msgText.text?.isEmpty ?? true {
            
            attachFileBtn.isHidden = false
            sendMsgBtn.isHidden = true
            
        }else{
            
            attachFileBtn.isHidden = true
            sendMsgBtn.isHidden = false
            
        }
    }
}



extension GroupChatVC: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
    }
    
    
    
}

extension GroupChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func setupImagePicker(){
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            //imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        guard let fileUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else { return }
        let name = fileUrl.lastPathComponent
        
        uploadImage(image, name)
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ rawImage: UIImage,_ imageName: String){
        
//        let thumbImage = Utils.resizeImage(image: rawImage, targetSize: CGSize(width: 50.0,height: 50.0))
        
        guard let data = rawImage.jpegData(compressionQuality: 1.0) else {
            present(UIAlertController(title: "Error", message: "Something went wront", preferredStyle: .alert), animated: true, completion: nil)
            return
        }
        
        //let imgData = profileImage.image?.jpegData(compressionQuality: 1.0) ?? Data()
        let imageSize = (Double(data.count) / 1000.0) / 1000.0
        print("imageSize = \(imageSize)")
        
        if imageSize < 10.0 {
            
           
            
        }
        //let thumbRef = profileImagesRef.child(currentUserID + "_thumbnail.jpg")
        // Upload the file to the path "images/rivers.jpg"
        
        let uniqueid = UUID()
        
        let imageUploadRef = storageRef.child("/images/\(uniqueid)/\(imageName)")
        
        imageUploadRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("Upload Error")
                return
            }
            
            print(metadata)
            // Metadata contains file metadata such as size, content-type.
            //let size = metadata.size
            // You can also access to download URL after upload.
            imageUploadRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                print(downloadURL)
                //self.userStateRef.setValue(downloadURL.absoluteString)
                self.saveMessage(message: downloadURL.absoluteString, type: "image")
            }
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
        
        let messageSenderID = currentUserID
        let fromUserID = messageData.uid ?? ""
        let fromMessageType = messageData.type
        let receiverName = messageData.name
        var receiverImage = messageData.photo
        
        if messageData.type == "text"{
            
            let textCell = tableView.dequeueReusableCell(withIdentifier: "CustomMessagesCell", for: indexPath) as! CustomMessagesCell
            
            textCell.receiverBox.isHidden = true
            textCell.senderBox.isHidden = true
            

            if receiverImage != LiveChatUtil.usersThumbnail[fromUserID] {
                receiverImage = LiveChatUtil.usersThumbnail[fromUserID]
            }
            
            let url = URL(string: receiverImage ?? "")
            let defaultImage = UIImage(named: "profile_image_thumbnail")
            
            textCell.receiverImage.kf.setImage(with: url, placeholder: defaultImage)
            
            if fromUserID == messageSenderID {
                
                textCell.senderBox.isHidden = false
                textCell.senderMessage.text = messageData.message
                textCell.senderMessage.numberOfLines = 0
                textCell.senderMessageDate.text = Utils.formatMessageTime(dateString: messageData.date ?? "")
                
            }else{
                
                textCell.receiverBox.isHidden = false
                textCell.receiverName.text = messageData.name
                textCell.receiverMessage.text = messageData.message
                textCell.receiverMessage.numberOfLines = 0
                textCell.receiverMessageDate.text = Utils.formatMessageTime(dateString: messageData.date ?? "")
                
            }
            
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
        //print("\(messageData.name)")
        
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
