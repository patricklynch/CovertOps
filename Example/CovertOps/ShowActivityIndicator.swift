import UIKit
import CovertOps

class ShowActivityIndicator: AsyncMainOperation<Void> {
    
    private weak var parentView: UIView?
    private var activityIndcatorView: UIView?
    private let animationDuration: TimeInterval
    
    init(in parentView: UIView, animationDuration: TimeInterval = 0.25) {
        self.parentView = parentView
        self.animationDuration = animationDuration
    }
    
    override func execute() {
        guard let parentView = parentView else {
            cancel()
            return
        }
        let activityIndcatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndcatorView.color = .black
        activityIndcatorView.frame = parentView.bounds
        activityIndcatorView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        activityIndcatorView.startAnimating()
        parentView.addSubview(activityIndcatorView)
        
        activityIndcatorView.alpha = 0.0
        UIView.animate(withDuration: animationDuration) {
            activityIndcatorView.alpha = 1.0
        }
        
        self.activityIndcatorView = activityIndcatorView
    }
    
    override func cancel() {
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.activityIndcatorView?.alpha = 0.0
            },
            completion: { _ in
                self.activityIndcatorView?.removeFromSuperview()
                self.finish()
            }
        )
    }
}
