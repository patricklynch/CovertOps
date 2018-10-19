import UIKit

class DemoCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    var viewData: DemoDescription? {
        didSet {
            titleLabel.text = viewData?.title
            subtitleLabel.text = viewData?.subtitle
        }
    }
}
