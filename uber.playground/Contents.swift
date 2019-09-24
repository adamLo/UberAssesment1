import Foundation

public typealias Callback = (_ notification: String, _ data: Any) -> Void

public protocol Observer: AnyObject {
    var callback: Callback { get }
}

public protocol NotificationCenter {
    func add(observer: Observer, for notification: String)
    func remove(observer: Observer, for notification: String)
    func post(notification: String, data: Any)
}

public final class NotificationCenterImpl: NotificationCenter {

    private(set) var observers = [String : [Observer]]()

    public func add(observer: Observer, for notification: String) {

        if var _observers = observers[notification] {
            if let _ = _observers.first(where: { (anObserver) -> Bool in
                return anObserver === observer
            }) {
                return
            }
            else {
                _observers.append(observer)
                observers[notification] = _observers
            }
        }
        else {
            observers[notification] = [observer]
        }
    }
    
    public func remove(observer: Observer, for notification: String) {

        if var _observers = observers[notification] {
            _observers.removeAll { (anObserver) -> Bool in
                anObserver === observer
            }
            observers[notification] = _observers
        }
    }
    
    public func post(notification: String, data: Any) {

        if let _observers = observers[notification] {
            
            for observer in _observers {
                observer.callback(notification, data)
            }
        }
    }
}

let notificationCenter = NotificationCenterImpl()

class MyObserver2: Observer {
    
    var callback: Callback = { (notification, data) in
        
        print("222 Got the notification: \(notification) with data: \(data)")
    }
}

class MyObserver: Observer {
    
    var callback: Callback
    
    init(newCallBack: @escaping Callback) {
        
        callback = newCallBack
    }
}

let myObserver = MyObserver(newCallBack: {(notification, data) in
       
       print("Got the notification: \(notification) with data: \(data)")
   }
)
let notification = "testNotification"
notificationCenter.add(observer: myObserver, for: notification)
let observer2 = MyObserver2()
notificationCenter.add(observer: observer2, for: notification)
notificationCenter.post(notification: notification, data: "Hello world")

print("1. Observers: \(notificationCenter.observers[notification]?.count ?? 0)")

notificationCenter.remove(observer: myObserver, for: notification)
print("2. Observers: \(notificationCenter.observers[notification]?.count ?? 0)")
