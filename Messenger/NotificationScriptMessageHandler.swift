//
//  NotificationScriptMessageHandler.swift
//  Messenger
//
//  Created by TeamiHackify on 6 of February 2016.
//

import Foundation
import WebKit

class NotificationScriptMessageHandler: NSObject, WKScriptMessageHandler, NSUserNotificationCenterDelegate {

    // MARK: - ContentController message handler

    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        
        let type = message.body["type"] as! NSString
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;
        
        switch type {
            case "NOT_LOGGED_IN":
                0
                //appDelegate.notLoggedIn()
                break
            case "LOADED":
                appDelegate.loadingView?.hidden = true
                break
            case "NOTIFICATION":
                let pictureUrl = NSURL(string: message.body["pictureUrl"] as! String)
                displayNotification(message.body["title"] as! NSString, text: message.body["text"] as! NSString, id: message.body["id"] as! NSString, picture: NSImage(contentsOfURL: pictureUrl!))
                break
            case "DOCK_COUNT":
                dockCount(message.body["content"] as! String)
                break
            case "SHOW_IMAGE":
                appDelegate.quicklookMediaURL = NSURL(string: (message.body["url"] as! String))
                break
            case "CHOOSE_IMAGE":
                appDelegate.menuHandler.sendImage(nil)
                break
            case "SET_TITLE":
                appDelegate.titleLabel.setTitle(message.body["title"] as! String, active: message.body["activity"] as! String)
                break
            case "LOG":
                print(message.body)
            default:
                0
        }
    }

    
    // MARK: - Dock Badge counter, Status Item state

    func dockCount(count: String) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;

        if (count == "0") {
            NSApplication.sharedApplication().dockTile.badgeLabel = ""
            appDelegate.changeStatusItemImage("StatusItem")
        } else {
            NSApplication.sharedApplication().dockTile.badgeLabel = count
            appDelegate.changeStatusItemImage("StatusItemUnread")
        }
    }


    // MARK: - OSX Notifications

    func displayNotification(title: NSString, text: NSString, id: NSString, picture: NSImage?) {
        let notification:NSUserNotification = NSUserNotification()
        notification.title = title as String
        notification.informativeText = text as String
        if let contentImage = picture {
            notification.contentImage = roundCorners(contentImage)
        }
        notification.deliveryDate = NSDate()
        notification.responsePlaceholder = "Reply"
        notification.hasReplyButton = true
        notification.userInfo = ["id":id]

        let notificationcenter:NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        notificationcenter.delegate = self
        notificationcenter.scheduleNotification(notification)
    }

    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate;
        let id = notification.userInfo!["id"] as! String
        if (notification.activationType == NSUserNotificationActivationType.Replied){
            let userResponse = notification.response?.string;
            appDelegate.webView.evaluateJavaScript("replyToNotification('" + id + "','" + userResponse! + "')", completionHandler: nil);
        } else {
            appDelegate.webView.evaluateJavaScript("reactivation('" + id + "')", completionHandler: nil);
        }
    }


    // MARK: - Image Processing
    
    func roundCorners(image: NSImage) -> NSImage {
        
        let existingImage = image
        let imageSize = existingImage.size
        let width = imageSize.width
        let height = imageSize.height
        let xRad = width / 2
        let yRad = height / 2
        let newSize = NSMakeSize(imageSize.height, imageSize.width)
        let roundedImage = NSImage(size: newSize)
        
        roundedImage.lockFocus()
        let ctx = NSGraphicsContext.currentContext()
        ctx?.imageInterpolation = NSImageInterpolation.High
        
        let imageFrame = NSRect(x: 0, y: 0, width: width, height: height)
        let clipPath = NSBezierPath(roundedRect: imageFrame, xRadius: xRad, yRadius: yRad)
        clipPath.windingRule = NSWindingRule.EvenOddWindingRule
        clipPath.addClip()
        
        let rect = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        image.drawAtPoint(NSZeroPoint, fromRect: rect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1)
        roundedImage.unlockFocus()
        
        return roundedImage
    }
    
}