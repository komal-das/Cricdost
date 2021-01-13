//
//  ShareViewController.swift
//  CricDost-Share
//
//  Created by Karthik on 7/30/20.
//  Copyright © 2020 XCEL Solutions Corp. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import Alamofire
import SwiftyJSON
import AVKit

class ShareViewController: SLComposeServiceViewController {
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        
        let contentType = kUTTypeImage as String
        let contentVideo = kUTTypeData as String
        
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType,
                                  options: nil) { [weak self] (data, error) in
                                    guard error == nil else { return }
                                    
                                    if let url = data as? URL,
                                        let imgData = try? Data(contentsOf: url) {
                                        self?.uploadMultipleImages(images: [imgData])
                                    } else {
                                        print("Impossible to save image")
                                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(contentVideo) {
                provider.loadItem(forTypeIdentifier: contentVideo,
                                  options: nil) { [weak self] (data, error) in
                                    guard error == nil else { return }
                                    
                                    if let url = data as? URL {
                                        if url.startAccessingSecurityScopedResource() {
                                            self?.uploadVideo(videoURL: url)
                                        }
                                    } else {
                                        print("Impossible to save image")
                                    }
                }
            }
        }
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
}

extension ShareViewController {
    
    func uploadMultipleImages(images:[Data]) {
        
        var subAction = ""
        var param: [String: String] = [:]
        var myurl = ""
        
        if let savedata =  UserDefaults.init(suiteName: "group.cricdost.shareDemo") {
            if let cricdostdata = savedata.value(forKey: "DEVICE_KEY") as? [String: Any] {
                subAction = "{\"DEVICE_KEY\":\"\(cricdostdata["DeviceKey"] as! String)\",\"POST\":\"\((self.contentText ?? "").replacingOccurrences(of: "\"", with: "\\\"", options: .literal, range: nil))\",\"IMAGE\":\"\",\"POST_ID\":\"\"}"
                
                param = [ "app" : "CRICDOST", "appId":cricdostdata["AppId"] as! String , "mod": "CricSpace", "actionType" : "add-post-new", "subAction": subAction ] as [String : String]
                
                myurl = cricdostdata["BaseUrl"] as! String
            }
        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            var i=0
            for imageData in images {
                multipartFormData.append(imageData, withName: "\(i)", fileName: "\(Date().timeIntervalSince1970).jpeg", mimeType: "image/jpeg")
                i+=1
            }
            for (key, value) in param {
                multipartFormData.append((value).data(using: String.Encoding.utf8)!, withName: key)
            }
            print(multipartFormData)
        }, to: myurl) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                upload.responseJSON { (response) in
                    
                    guard let value = response.result.value else {
                        print("Unknown error. Please try again")
                        return
                    }
                    print("result fetched successfull", JSON(value))
                    
                }
                
                break
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
    }
    
    func uploadVideo(videoURL: URL) {
        
        var subAction = ""
        var param: [String: String] = [:]
        var myurl = ""
        
        if let savedata =  UserDefaults.init(suiteName: "group.cricdost.shareDemo") {
            if let cricdostdata = savedata.value(forKey: "DEVICE_KEY") as? [String: Any] {
                subAction = "{\"DEVICE_KEY\":\"\(cricdostdata["DeviceKey"] as! String)\",\"POST\":\"\((self.contentText ?? "").replacingOccurrences(of: "\"", with: "\\\"", options: .literal, range: nil))\",\"IMAGE\":\"\",\"POST_ID\":\"\"}"
                
                param = [ "app" : "CRICDOST", "appId":cricdostdata["AppId"] as! String , "mod": "CricSpace", "actionType" : "add-post-new", "subAction": subAction ] as [String : String]
                
                myurl = cricdostdata["BaseUrl"] as! String
            }
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(videoURL, withName: "IMAGE", fileName: "video.mp4", mimeType: "video/mp4")
            for (key, value) in param {
                multipartFormData.append((value).data(using: String.Encoding.utf8)!, withName: key)
            }
            print(multipartFormData)
        }, to: myurl) { (result) in
            videoURL.stopAccessingSecurityScopedResource()
            switch result {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    
                })
                upload.responseJSON { (response) in
                    
                    guard let value = response.result.value else {
                        print("Unknown error. Please try again")
                        return
                    }
                    print(JSON(value))                    
                }
                
                break
            case .failure(let encodingError):
                print(encodingError)
                break
            }
        }
    }
}


