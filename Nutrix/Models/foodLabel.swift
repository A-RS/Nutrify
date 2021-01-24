//
//  foodLabel.swift
//  Nutrix
//
//  Created by Ananya Jajoo on 1/18/21.
//

import UIKit

protocol checkButtonDelagate {
    func didTapCheckBtn()
}

class foodLabel: UITableViewCell{ 
    @IBOutlet weak var ingredientField: UILabel!
    var delegate: checkButtonDelagate?
    
    @IBOutlet weak var checkMark: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    @IBAction func checkBtn(_ sender: UIButton) {
        delegate?.didTapCheckBtn()
        checkMark.isEnabled = false
        checkMark.alpha = 0.5
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func xBtn(_ sender: UIButton) {
        
    }

}
