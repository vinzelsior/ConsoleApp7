//
//  ControlCells.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 24.08.21.
//

import Foundation
import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    func configure(bttn1: String, bttn2: String ) {
        
        button1.setTitle(bttn1, for: .normal)
        button2.setTitle(bttn2, for: .normal)
    }
    
    
}

class SliderCell: UITableViewCell {
    @IBOutlet weak var slider: UISlider!
}

class SegmentCell: UITableViewCell {
    // who even knows...
    var what: (Int) -> Void = { _ in }
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func didChange(_ sender: Any) {
        let s = sender as! UISegmentedControl
        what(s.selectedSegmentIndex)
    }
}
