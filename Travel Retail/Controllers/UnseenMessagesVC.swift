//
//  UnseenMessagesVC.swift
//  Travel Retail
//
//  Created by Anis Mizi on 5/25/19.
//  Copyright © 2019 AL HARAMAIN. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Firebase

class UnseenMessagesVC: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var unSeenMsgTable: UITableView!
    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupContainer: UIView!
    @IBOutlet weak var groupTotalMsgs: UILabel!
    var ref: DatabaseReference!
    var groupMembersRef: DatabaseReference!
    var groupUnseenRef: DatabaseReference!
    var usersRef: DatabaseReference!
    var stateRef: DatabaseReference!
    
    var usersDataList: [MemberCellData] = []
    var currentUserID = ""
    let chatGroup = UserDefaults.standard.string(forKey: Utils.CHAT_GROUP) ?? ""
    
    var allStateRefs: [DatabaseReference] = []
    var allStateEvents: [DatabaseHandle] = []
    
    var allUserRefs: [DatabaseReference] = []
    var allUserEvents: [DatabaseHandle] = []
    
    var allUnseenRefs: [DatabaseReference] = []
    var allUnseenEvents: [DatabaseHandle] = []
    
    var isConnected = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
        currentUserID = user?.uid ?? ""
        
        ref = Database.database().reference()
        groupMembersRef = ref.child("Unread Messages").child(currentUserID)
        groupUnseenRef = ref.child("Groups Unread").child(currentUserID)
        usersRef = ref.child("Users")
        stateRef = ref.child("userState")
        
        groupName.text = chatGroup
        groupContainer.isHidden = true
        
        unSeenMsgTable.delegate = self
        unSeenMsgTable.dataSource = self
        
        unSeenMsgTable.rowHeight = UITableView.automaticDimension
        
        retreiveMessages()
        retreiveGroupMessages()
        
        if !Utils.isConnectedToNetwork(){
            isConnected = false
            view.makeToast("No Interner Connection.")
        }
        
        
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo("Unseen Messages")
    }
    
    func retreiveMessages(){
        
        // Listen for new comments in the Firebase database
        groupMembersRef.observe(.childAdded, with: { (snapshot) -> Void in
            
            //let memberData = snapshot.value as? NSDictionary
            
            
            let id = snapshot.key
            //print("CurrentID: \(self.currentUserID) userID: \(id)")
            
            if(id != self.currentUserID){
                //self.usersIdList.append(id)
                
                let memberData = MemberCellData()
                
                self.usersDataList.append(memberData)
                //self.membersTable.reloadData()
                
                let indexPath = IndexPath(row: self.usersDataList.count - 1, section: 0)
                
                DispatchQueue.main.async {
                    self.unSeenMsgTable.beginUpdates()
                    self.unSeenMsgTable.insertRows(at: [indexPath], with: .automatic)
                    self.unSeenMsgTable.endUpdates()
                }
                
                let uStateRef = self.stateRef.child(id)
                //let uStateHandle =
                let uStateHandle = uStateRef.observe(.value, with: { (snapshot) -> Void in
                    
                    if snapshot.hasChild("thumbnail"){
                        memberData.profileImage = snapshot.childSnapshot(forPath: "thumbnail").value as? String ?? ""
                        print(memberData.profileImage)
                        
                    }
                    
                    if snapshot.hasChild("state"){
                        
                        let state = snapshot.childSnapshot(forPath: "state").value as? String ?? ""
                        let date = snapshot.childSnapshot(forPath: "state").value as? String ?? ""
                        
                        print("\(state) \(date)")
                        
                        if state == "online" && self.isConnected{
                            
                            memberData.userStatus = "online"
                            
                        }else if state == "offline" {
                            
                            let lastSeen = Utils.formatMessageTime(dateString: date)
                            memberData.userStatus = "Last Seen: \(lastSeen)"
                        }
                        
                    }else {
                        memberData.userStatus = "offline"
                    }
                    
                    self.reloadUserCell(indexPath: indexPath)
                    
                    print("Inside userStatus \(memberData.userStatus)")
                    
                })
                
                self.allStateRefs.append(uStateRef)
                self.allStateEvents.append(uStateHandle)
                
                let uDataRef = self.usersRef.child(id)
                
                let uDataHandle = uDataRef.observe(.value, with: { (snapshot) -> Void in
                    
                    memberData.profileName = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
                    
                    print("Inside profileName \(memberData.profileName)")
                    
                    self.reloadUserCell(indexPath: indexPath)
                })
                
                self.allUserRefs.append(uDataRef)
                self.allUserEvents.append(uDataHandle)
                
                let unseenRef = self.ref.child("Unread Messages")
                let uUnseenHandle = unseenRef.observe(.value, with: { (snapshot) -> Void in
                    
                    let total_msgs = snapshot.childrenCount
                    memberData.unseenMsg = "\(total_msgs) New Messages"
                    
                    print("Inside unseenMsg \(total_msgs)")
                    
                    self.reloadUserCell(indexPath: indexPath)
                    
                    /*self.membersTable.beginUpdates()
                     self.membersTable.moveRow(at: self.membersTable[0], to: self.membersTable[1])
                     self.membersTable.moveRow(at: indexPath2, to: indexPath1)
                     self.membersTable.endUpdates()*/
                })
                
                self.allUnseenRefs.append(unseenRef)
                self.allUnseenEvents.append(uUnseenHandle)
                
                print("Inside firebase \(memberData.profileName)")
                
                
                
            }
            
            //Utils.usersThumbnail[id] = "na"
            
            /*self.membersTable.insertRows(at: [IndexPath(row: self.usersIdList.count-1, section: self.kSectionComments)], with: UITableView.RowAnimation.automatic)*/
        })

        
    }
    
    func retreiveGroupMessages(){
        groupUnseenRef.observe(.value, with: {(snapshot) in
            let total_msgs = snapshot.childrenCount
            self.groupTotalMsgs.text = "\(self.chatGroup) \(total_msgs) New Messages"
            self.groupContainer.isHidden = false
        }){ (error) in
            self.groupTotalMsgs.text = "\(self.chatGroup) No New Messages"
        }
    }
    
    func reloadUserCell(indexPath: IndexPath){
        
        DispatchQueue.main.async {
            self.unSeenMsgTable.beginUpdates()
            self.unSeenMsgTable.reloadRows(at: [indexPath], with: .automatic)
            self.unSeenMsgTable.endUpdates()
        }
        
    }
    

}

extension UnseenMessagesVC: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let userData = usersDataList[indexPath.row]
        
        print("Inside tableRow \(userData)")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnseenMsgCell") as! UnseenMsgCell
        
        cell.unseenMsgCell(memberCellData: userData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userData = usersDataList[indexPath.row]
        print("\(userData.profileName)")
        
        /*let alertVc = alertService.priceListDetailsAlert()
         alertVc.productInfo = product
         present(alertVc,animated: true)*/
        
    }
    
}
