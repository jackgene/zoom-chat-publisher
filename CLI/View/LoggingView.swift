import Foundation
import Logging
import RxSwift
import ZoomChatPublisher

/// View that simply logs events to the console.
struct LoggingView: View {
    static let log: Logging.Logger = Logging.Logger(label: "main")
    
    private func render(_ eventResult: Result<PublishEvent, PublishError>) {
        switch eventResult {
        case .success(.publish(let publishAttempt)):
            switch publishAttempt.httpResponseResult {
            case .success(let response):
                let statusCode: Int = response.statusCode
                response.url.map { (url: URL) in
                    if statusCode == 204 {
                        Self.log.info("POSTed to \(url)")
                    } else {
                        Self.log.warning("Got \(statusCode) POSTing to \(url)")
                    }
                }
                
            case .failure(let error):
                switch error {
                case let urlError as URLError:
                    urlError.failingURL.map { (url: URL) in
                        print(#""\#(urlError.localizedDescription)" POSTing to \#(url)"#)
                    }
                default: Self.log.warning("\(error)")
                }
            }
            
        case .success(.noOp):
            break
            
        case .failure(let error):
            switch error {
            case .zoomNotRunning:
                Self.log.info("Zoom not running")
            case .noMeetingInProgress:
                Self.log.info("No meeting in progress")
            case .chatNotOpen:
                Self.log.info("Chat not open")
            }
        }
    }
    
    func render(_ events: Observable<Result<PublishEvent, PublishError>>) -> Disposable {
        events.subscribe(onNext: render)
    }
}
