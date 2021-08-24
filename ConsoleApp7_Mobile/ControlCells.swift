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
    
    private var f1: () -> Void = {}
    private var f2: () -> Void = {}
    
    func configure(f1: @escaping () -> Void, bttn1: String, f2: @escaping () -> Void, bttn2: String ) {
        self.f1 = f1
        self.f2 = f2
        
        button1.setTitle(bttn1, for: .normal)
        button2.setTitle(bttn2, for: .normal)
    }
    
    @IBAction func didPress(_ sender: Any) {
        let bttn = sender as! UIButton
        
        if bttn.tag == 10 { f1() }
        if bttn.tag == 20 { f2() }
        
    }
    
    
}

class SliderCell: UITableViewCell {
    @IBOutlet weak var slider: UISlider!
}

class SegmentCell: UITableViewCell {
    @IBOutlet weak var segment: UISegmentedControl!
}
