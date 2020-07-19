//
//  QuickBloxHelper.swift
//  VideoCallTest
//
//  Created by Teena Nath Paul on 14/06/17.
//  Copyright © 2017 Teena Nath Paul. All rights reserved.
//

import UIKit
import SystemConfiguration
import MobileCoreServices
import Quickblox
import QuickbloxWebRTC

//let KQuickBloxApplicationId:UInt = 76138
//let KQuickBloxAccountKey = "Fz1y82cRN4ssoWY63yhs"
//let KQuickBloxAuthorizationKey = "AWRKL6eKH27Zw96"
//let KQuickBloxAuthorizationSecret = "2daU3zdnMpLhe8j"

let KQuickBloxApplicationId:UInt = 76912
let KQuickBloxAccountKey = "9CUph7CxWWQmGTCoRqzq"
let KQuickBloxAuthorizationKey = "ne4Q4ecGPzg5xaz"
let KQuickBloxAuthorizationSecret = "LF3WUj925RQM7Et"


let KUserDefault                =  UserDefaults.standard
let kUserId             =       "userId"
let kHintText           =  "extra_info_hint"
let kId                 =       "id"



class QuickBloxHelper: NSObject, QBChatDelegate, QBRTCClientDelegate, QBRTCBaseClientDelegate, QBRTCAudioSessionDelegate
{
    var newSession:QBRTCSession?
    var lastCallTimeInterval : TimeInterval?
    var currentUser: QBUUser?
    var qrclient: QBRTCClientDelegate?
    var didReceiveVideoCall:(()->())?
    var callDidAcceptByOpponent:(()->())?
    var callDidEndCallBack:(()->())?
    var callDidReceiveOpponentVideo:((QBRTCBaseSession,QBRTCVideoTrack,NSNumber)->Void)?
    
    static let sharedInstance : QuickBloxHelper = {
        let instance = QuickBloxHelper()
        return instance
    }()
    
    override init()
    {
        super.init()
    }
    
    func initializeQuickBlox()
    {
        //        QBSettings.setApplicationID(UInt(KQuickBloxApplicationId))
        //        QBSettings.setAccountKey(KQuickBloxAccountKey)
        //        QBSettings.setAuthKey(KQuickBloxAuthorizationKey)
        //        QBSettings.setAuthSecret(KQuickBloxAuthorizationSecret)
        //        QBSettings.setAutoReconnectEnabled(true)
        //        QBChat.instance().addDelegate(self)
        
        QBSettings.applicationID = UInt(KQuickBloxApplicationId)
        QBSettings.accountKey = KQuickBloxAccountKey
        QBSettings.authKey = KQuickBloxAuthorizationKey
        QBSettings.authSecret = KQuickBloxAuthorizationSecret
        QBSettings.autoReconnectEnabled = true
        QBChat.instance.addDelegate(self)
        
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        QBRTCConfig.setAnswerTimeInterval(45)
        QBRTCConfig.setDialingTimeInterval(15)
        QBRTCConfig.setDTLSEnabled(true)
        
        QBRTCAudioSession.instance().initialize()
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    func logoutUser() {
        QBRequest.logOut(successBlock: { (qbResponse) in
            print("------------ You are Logged out from the Session")
        }) { (qbResponse) in
            print("------------ An Error Has occured---------")
        }
    }
    
    func deleteCurrentUser() {
        let logoutGroup = DispatchGroup()
        logoutGroup.enter()
        QBChat.instance.disconnect(completionBlock: { error in
            logoutGroup.leave()
        })
        logoutGroup.notify(queue: .main) {
            // Delete user from server
            QBRequest.deleteCurrentUser(successBlock: { response in
                print("User successfully deleted")
            }, errorBlock: { response in
                print("An Error has Occurred")
            })
        }
    }
    
    func getUserByEmail(email: String,onCompletion:@escaping (_ isSuccess: Bool,_ response:UInt)->Void)
    {
        SwiftHelper.showLoader(message: "")
        
        QBRequest.user(withEmail:email, successBlock: { (qbResponse, qbUser) in
            
            SwiftHelper.dismissLoader()
            
            let opponentId = qbUser.id
            
            onCompletion(true,opponentId)
            
        }) { (errorResponse) in
            
            onCompletion(false,1)
        }
    }
    
    func getUserByFullName(_ fullName: String,onCompletion:@escaping (_ isSuccess: Bool,_ response:UInt)->Void)
    {
        SwiftHelper.showLoader(message: "")
        
        let pages = QBGeneralResponsePage.init(currentPage: 1, perPage: 50)
        
        QBRequest.users(withFullName:fullName, page: pages, successBlock: { (qbResponse, page, qbUser) in
            SwiftHelper.dismissLoader()
            print("the user ")
        }) { (errorResponse) in
            onCompletion(false,1)
        }
        
    }
    
    func getUserByExterNalId(_ exterNalId: String,onCompletion:@escaping (_ isSuccess: Bool,_ response:UInt)->Void)
    {
        SwiftHelper.showLoader(message: "")
        
        QBRequest.user(withExternalID: UInt(exterNalId)! , successBlock: { (qbResponse, qbUser) in
            SwiftHelper.dismissLoader()
            let opponentId = qbUser.id
            onCompletion(true,opponentId)
        }) { (errorResponse) in
            SwiftHelper.dismissLoader()
            onCompletion(false,1)
        }
    }
    
    /**
     *  Signup and login
     *
     *  @param fullName User name
     *  @param roomName room name (tag)
     */
    class func signUp(withFullName fullName: String?, roomName: String?) {
        let newUser = QBUUser()
        newUser.login = UUID().uuidString
        newUser.fullName = fullName
        newUser.tags = [roomName] as? [String]
        newUser.password = "12345678"
        
        // self.setLoginStatus(LoginStatusConstant.signUp)
        
        QBRequest.signUp(newUser, successBlock: { response, user in
            QuickBloxHelper.loginWithCurrentUser(user)
        }, errorBlock: { response in
            print("The Response Error Code is --->", response)
        })
    }
    
    /**
     *  login
     */
    class func loginWithCurrentUser(_ user:QBUUser) {
        
        QBRequest.logIn(withUserLogin: user.login!,
                        password: "12345678",
                        successBlock: { response, user in
                            print("The Response is --->",response)
        }, errorBlock: { response in
            print("The Response Error Code is --->", response)
        })
        
    }
    
    
    
    class func createUserWithEmailID(_ deviceToken:String,email: String, password: String, externalID:String,fullName: String,onCompletion:@escaping (_ isSuccess: Bool,_ response: Dictionary<String,Any>)->Void)
    {
        let user = QBUUser()
        user.password = "12345678"
        user.fullName = fullName
        user.login = email//UUID().uuidString
        user.externalUserID = UInt(externalID)!
        //user.tags = ["TutorLand"]
        QBRequest.signUp(user, successBlock: { (qbResponse, qbUser) in
            
            KUserDefault.set(qbUser.id, forKey:"opponentId")
            
            print("the Id Is ----->",KUserDefault.value(forKey:"opponentId") ?? "")
            
            QuickBloxHelper.sharedInstance.currentUser = qbUser
            
            KUserDefault.set(qbUser.login, forKey: "qblogin")
            
            onCompletion(true, ["login":user.login!])
            
        }) { (errorResponse) in
            
            if let error = errorResponse.error, let dictReason = error.reasons{
                let keys = dictReason.keys
                
                if keys.contains("errors") {
                    if let dictData = dictReason["errors"] as? [String:Any]   {
                        let keys = dictData.keys
                        if keys.contains("external_user_id") {
                            KUserDefault.set(user.login, forKey: "qblogin")
                            
                            // onCompletion(true, ["login":user.login!])
                        }
                    }
                } else {
                    onCompletion(false, ["":""])
                }
            }
            onCompletion(false, ["":""])
        }
    }
    
    
    class func loginUserWithEmail(_ userLogin:String,userEmail: String, password: String, loginCompletionBlock:@escaping (_ success: Bool)-> Void)
    {
        print("logging in using -" + userEmail + "- as userEmail")
        print("logging in using -" + password + "- as password")
        QBRequest.logIn(withUserLogin: userLogin, password: password, successBlock: { (qbResponse, qbUser) in
            if qbUser != nil
            {
                let userChatId = qbUser.id
                let user = QBUUser()
                user.id = userChatId
                user.password = password
                
                self.connectWithUser(user: user, onCompletionBlock: { (error) in
                    
                    if error == nil
                    {
                        UserDefaults.qbEmail = userEmail
                        UserDefaults.qbPassword = password
                        UserDefaults.qbUserId = String(userChatId)
                        
                        loginCompletionBlock(true)
                        print("User Connect Successfully")
                        let extendedRequest = ["sort_desc" : "_id"]
                         
                        let page = QBResponsePage(limit: 100, skip: 0)
                         
                        QBRequest.dialogs(for:page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
                         
                            }) { (response: QBResponse) -> Void in
                         
                        }
                        var chatDialog: QBChatDialog = QBChatDialog(dialogID: nil, type: QBChatDialogType.private)
                        chatDialog.occupantIDs = [101658190]
                         
                        QBRequest.createDialog(chatDialog, successBlock: {(response: QBResponse?, createdDialog: QBChatDialog?) in
                         
                        }, errorBlock: {(response: QBResponse!) in
                         
                        })
                         
                        
                        
                        
                        
                         
                    }
                    else
                    {
                        loginCompletionBlock(false)
                        print("User Connect Failed",error)
                    }
                })
            }
            else
            {
                loginCompletionBlock(false)
                print("User Login Failed")
            }
            
        }) { (qbResponse) in
            print(qbResponse)
            loginCompletionBlock(false)
            print("User Login Failed")
        }
        //        QBRequest.logIn(withUserEmail: userEmail, password: password, successBlock: { (qbResponse, qbUser) in
        //
        //            if qbUser != nil
        //            {
        //                let userChatId = qbUser.id
        //                let user = QBUUser()
        //                user.id = userChatId
        //                user.password = password
        //
        //                self.connectWithUser(user: user, onCompletionBlock: { (error) in
        //
        //                    if error == nil
        //                    {
        //                        UserDefaults.qbEmail = userEmail
        //                        UserDefaults.qbPassword = password
        //                        UserDefaults.qbUserId = String(userChatId)
        //
        //                        loginCompletionBlock(true)
        //                        print("User Connect Successfully")
        //                    }
        //                    else
        //                    {
        //                        loginCompletionBlock(false)
        //                        print("User Connect Failed")
        //                    }
        //                })
        //            }
        //            else
        //            {
        //                loginCompletionBlock(false)
        //                print("User Login Failed")
        //            }
        //
        //        }) { (qbResponse) in
        //
        //            print(qbResponse)
        //            loginCompletionBlock(false)
        //            print("User Login Failed")
        //        }
    }
    
    func sendPushToOponent(_ oponentId:String) {
        QBRequest.sendPush(withText: "Hii SomeOne is calling you", toUsers: oponentId, successBlock: { (response, event) in
            print("Push sent!")
        }) { (error) in
            print("Can not send push: \(error)")
        }
    }
    
    private class func connectWithUser(user: QBUUser,onCompletionBlock:@escaping (_ error: Error?)-> Void)-> Void
    {
        QBChat.instance.connect(with: user) { (error) in
            
            onCompletionBlock(error)
        }
    }
    
    class func disconnectWithCompletionBlock(block:@escaping (_ error: Error?)-> Void)-> Void
    {
        QBChat.instance.disconnect { (error) in
            
            block(error)
        }
    }
    
    class func getCurrentSession() -> QBRTCSession?
    {
        return QuickBloxHelper.sharedInstance.newSession
    }
    
    func makeCall(toQBId id : UInt, hintText : String, tutorId : String, videoCallId: String)
    {
        QBRTCClient.instance().add(self) // self class must conform to QBRTCClientDelegate protocol
        
        // 2123, 2123, 3122 - opponent's
        let opponentsIDs = [id]
        newSession = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs as [NSNumber], with: QBRTCConferenceType.video)
        // userInfo - the custom user information dictionary for the call. May be nil.
        let userInfo :[String:String] = [kUserId:String(id),
                                         kHintText:hintText,
                                         "extra_caller_user_id" : SwiftHelper.convertToString(obj: KUserDefault.object(forKey: kId)),
                                         "extra_receiver_user_id" : tutorId,
                                         "extra_video_call_id" : videoCallId]
        
        
        newSession?.startCall(userInfo)
    }
    
    func toggleSpeaker(mode status:Bool)
    {
        if status == true
        {
            QBRTCAudioSession.instance().currentAudioDevice = QBRTCAudioDevice.speaker
        }
        else
        {
            QBRTCAudioSession.instance().currentAudioDevice = QBRTCAudioDevice.receiver
        }
    }
    
    func acceptCall()
    {
        let userInfo :[String:String] = ["email" : UserDefaults.qbEmail ?? ""]
        if let _ = QuickBloxHelper.sharedInstance.newSession
        {
            QuickBloxHelper.sharedInstance.newSession!.acceptCall(userInfo)
            
            ShareData.video_chat_start_status = false
            UIApplication.shared.keyWindow?.setRootViewController(MainVideoChatVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
        }
    }
    
    func toggleMuteCall()
    {
        if newSession != nil
        {
            newSession?.recorder?.isMicrophoneMuted = !(newSession?.recorder?.isMicrophoneMuted)!
        }
    }
    
    func rejectCall()
    {
        let userInfo :[String:String] = ["email" : UserDefaults.qbEmail ?? ""]
        if let _ = QuickBloxHelper.sharedInstance.newSession
        {
            QuickBloxHelper.sharedInstance.newSession!.rejectCall(userInfo)
            QuickBloxHelper.sharedInstance.newSession = nil
            
            UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
            
        }
    }
    
    func endCall(remoteView:QBRTCRemoteVideoView)
    {
        if self.newSession != nil
        {
            let email = UserDefaults.qbEmail ?? ""
            let userInfo :[String:String] = ["email": email]
            self.newSession?.hangUp(userInfo)
            self.newSession = nil
            lastCallTimeInterval = CallTimmer.sharedInstance.endCallTimer()
            print("Total Call Durantion " + String(describing: lastCallTimeInterval))
        }
    }
    
    func showCallingView(hintText: String, tutorId: String, videoCallId: String)
    {
        guard let activeVieC = SwiftHelper.topMostController()
            else
        {
            return
        }
        
        
        ShareData.selected_book = ShareData.books.filter { $0.book.id! == videoCallId }[0]
        UIApplication.shared.keyWindow?.setRootViewController(MainVideoReceiveVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
        
    }
    
    //MARK: Delegates
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil)
    {
        if self.newSession != nil
        {
            // we already have a video/audio call session, so we reject another one
            // userInfo - the custom user information dictionary for the call from caller. May be nil.
            let userInfo :[String:String] = ["userId":"value"]
            session.rejectCall(userInfo)
        }
        else
        {
            self.newSession = session
            if didReceiveVideoCall != nil
            {
                didReceiveVideoCall?()
            }
            let hintText = SwiftHelper.convertToString(obj: userInfo?[kHintText])
            let userId = SwiftHelper.convertToString(obj: userInfo?["extra_caller_user_id"])
            let videoCallId = SwiftHelper.convertToString(obj: userInfo?["extra_video_call_id"])
            
            self.showCallingView(hintText: hintText, tutorId: userId, videoCallId: videoCallId)
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        if callDidEndCallBack != nil
        {
            callDidEndCallBack?()
            callDidEndCallBack = nil
            self.newSession = nil
            
            let send_time = CommonFuncs().currentTime()
            
            let parmeters = ["book_id": ShareData.selected_book.book.id!, "time": send_time, "time_zone": ShareData.user_info.time_zone!] as [String: Any]
            
            CommonFuncs().createRequest(false, "book/finish", "POST", parmeters, completionHandler: {data in
                
                let status = data["status"] as! Bool
                let message = data["message"] as! String
                
                DispatchQueue.main.async {
                    
                    UIApplication.shared.keyWindow?.setRootViewController(MainVideoReviewVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn), slide_direction: .fromLeftToRight)
                    
                }
            })
            
        }
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        self.newSession = session
        if callDidAcceptByOpponent != nil
        {
            callDidAcceptByOpponent?()
        }
    }
    
    
    ///// call end function
    
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil)
    {
        if callDidEndCallBack != nil
        {
            callDidEndCallBack?()
            callDidEndCallBack = nil
            self.newSession = nil
            
            CommonFuncs().doneAlert(ShareData.appTitle, "You can`t call \(ShareData.selected_book.profile.name!) now", "CLOSE", {UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)})
            
        }
    }
    
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber)
    {
        if callDidEndCallBack != nil
        {
            callDidEndCallBack?()
            callDidEndCallBack = nil
            self.newSession = nil
            
            ShareData.main_tab_index = 2
            UIApplication.shared.keyWindow?.setRootViewController(MainTabVC(), options: UIWindow.TransitionOptions(direction: .toLeft, style: .easeIn), slide_direction: .fromLeftToRight)
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber)
    {
        if callDidReceiveOpponentVideo != nil
        {
            callDidReceiveOpponentVideo?(session,videoTrack,userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber)
    {
        
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber)
    {
        
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber)
    {
       
//        UIApplication.shared.keyWindow?.setRootViewController(MainVideoReviewVC(), options: UIWindow.TransitionOptions(direction: .toRight, style: .easeIn))
    }
}
