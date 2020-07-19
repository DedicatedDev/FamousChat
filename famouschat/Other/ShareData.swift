//
//  ShareData.swift
//  famouschat
//
//  Created by T-Tech Solutions LLC on 04/11/2018.
//  Copyright © 2018 T-Tech Solutions LLC. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

extension Notification.Name {
    
    static let chat_reload = Notification.Name("chat_reload")
    static let msg_unread_num = Notification.Name("msg_unread_num")
    static let msg_list_reload = Notification.Name("msg_list_reload")
    static let time_added = Notification.Name("time_added")
}

class ShareData: NSObject
{
    
    static let main_url = "http://zfp.sei.mybluehost.me/api/"
    static let appTitle = "chatterli"
    static let progress_index = 23
    static let btn_color = "10A7BA"
    static let star_color = "4997FF"
    static let star_non_color = "BCE0FD"
    static let photo_tint_color = UIColor.init(red: 0, green: 0.5, blue: 1, alpha: 1)
    static let btn_radius = 4
    static let month_names = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    static let month_short_names = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    
    
    static var badge_num = 0
    static var main_or_more_status = true
    static var app_config: ConfigMDL!
    static var user_info: UserMDL!
    static var rank_info: RankMDL!
    static var category_list: [CategoryMDL]!
    static var charity_list: [CharityMDL]!
    
    static var following_influencers = [UserMDL]()
    static var top_influencers = [UserMDL]()
    static var matched_influencers = [UserMDL]()
    
    static var feeds = [FeedMDL]()
    static var books = [BookMDL]()
    static var messages = [MessageMDL]()
    static var reviews = [ReviewMDL]()
    static var auctions = [AuctionMDL]()
    
    static var selected_influencer: UserMDL!
    static var selected_day_books = [BookMDL]()
    static var selected_user_books = [BookMDL]()
    static var selected_chat: MessageMDL!
    static var chat_msg_list = [MessageMDL]()
    
    static var new_following_list = [UserMDL]()
    static var auciton_create_edit = false
    
    static var auction_list = [AuctionMDL]()
    static var selected_auction: AuctionMDL!
    static var selected_auction_bidders = [AuctionBidMDL]()
    static var selected_charity_auctions = [AuctionMDL]()
    
    static var trend_selected_category: CategoryMDL!
    
    static var profile_photo: NSData! = nil
    static var profile_category: String! = ""
    
    static var msg_noti_status = false
    static var chat_status = false
    
    static var video_chat_start_status: Bool!
    
    static var user_or_influencer = true
    static var main_tab_index = 0
    
    static var book_selected_date: String = ""
    static var booking_time = ""
    static var booking_duration = ""
    static var booking_question = ""
    static var booking_popcoin = ""
    
    static var selected_book: BookMDL!
    static var pay_from_status = false
    static var review_from_status = false
    
    static var user_detail_profile: UserMDL!
    static var user_detail_reviews = [ReviewMDL]()
    
    static var rate_or_follow_status = true
    static var follow_or_following = "0"
    
    static var add_time = ""
    
    static var msg_vc_from = "1"
    static var book_detail_from_status = true
    
    static let progressDlgs = {
        return NVActivityIndicatorType.allCases.filter { $0 != .blank }
    }()
    
    struct feed_type {
        
        let auction_create = "11"
        let auction_update = "12"
        let auction_follow = "13"
        let auction_bid = "14"
        let auction_bid_update = "15"
        let auction_win = "16"
        
        let book_request = "21"
        let book_accept = "22"
        let book_cancel = "23"
        let book_add_time = "24"
        let book_start = "25"
        let book_video_sent = "26"
        let book_video_seen = "27"
        
        let follow_request = "31"
        let follow_accept = "32"
        let follow_cancel = "33"
        
        let review_left = "41"
        
        let msg_left = "51"
        let msg_typing = "52"
        let fee_msg = "53"
        
        let other_popcoin_zero = "61"
        let other_book_fee_charged = "62"
        let other_book_fee_received = "63"
        let other_book_fee_refunded = "64"
        let other_book_add_time = "65"
        let other_book_time_over = "66"
        let other_book_process_fee = "67"
        
        let promotion = "90"
        let feed_space = "92"
    }
    
    static let time_zones = ["-11", "-10", "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1", "0", "+1", "+2", "+3", "+4", "+5", "+6", "+7", "+8", "+9", "+10", "+11", "+12"]
    
}


