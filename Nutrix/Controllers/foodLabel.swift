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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func checkBtn(_ sender: UIButton) {
        delegate?.didTapCheckBtn()
        print("i am there")
    }
    
    @IBAction func xBtn(_ sender: UIButton) {
        
    }
}
