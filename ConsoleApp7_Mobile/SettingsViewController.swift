//
//  SettingsViewController.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 25.08.21.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: ControlHandling?
    
    var bttn1: UIButton?
    var bttn2: UIButton?
    var slider: UISlider?
    var segment: UISegmentedControl?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 55
        
        //contrastButton.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            
            //cell.configure(f1: contrast, bttn1: "Increase Contrast", f2: colorBttn, bttn2: "Multicolor")
            
            cell.configure(bttn1: "Contrast", bttn2: "Multicolor")
            
            bttn1 = cell.button1
            bttn2 = cell.button2
            
            cell.button1.addTarget(self, action: #selector(bing(sender:)), for: .touchUpInside)
            cell.button2.addTarget(self, action: #selector(bing(sender:)), for: .touchUpInside)
            
            // settings should be set here (whether it's active or not )
            
            return cell
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderCell") as! SliderCell
            
            cell.slider.addTarget(self, action: #selector(bang(sender:)), for: .valueChanged)
            
            slider = cell.slider
            
            // settings should be set here (the standard value of the slider )
            
            return cell
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell") as! SegmentCell
            
            segment = cell.segment
            
            cell.what = delegate!.segmentSelected(index:)
            
            // settings should be set here (the standard value of the segment )
            
            return cell
        }
        
        
        print("non.")
        return UITableViewCell()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        
        case 0:
            return "Color Setting"
        case 1:
            return "Resolution"
        case 2:
            return "Shading Mode"
        default:
            print("non.")
            return "bitch!"
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    
    // buttons
    @objc private func bing(sender: Any) {
        let button = sender as! UIButton
        delegate?.buttonPressed(tag: button.tag)
    }
    
    // slider
    @objc private func bang(sender: Any) {
        let s = sender as! UISlider
        delegate?.sliderChanged(value: s.value)
    }
    
    @IBAction func close(_ sender: Any) {
        
        if let vc = parent as? ViewController {
            unblur(vc.blurView)
        }
    }
    
    func unblur(_ view: UIView) {
        if let effectView = view as? UIVisualEffectView {
            UIView.animate(withDuration: 0.2) { () -> Void in
                effectView.effect = nil
                self.view.alpha = 0
            } completion: { _ in
                view.isHidden = true
            }
        }
    }
    
  
}
