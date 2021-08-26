//
//  SettingProtocol.swift
//  ConsoleApp7_Mobile
//
//  Created by Cedric Zwahlen on 25.08.21.
//

import Foundation
import UIKit

protocol ControlHandling {

    func buttonPressed(tag: Int)
    func sliderChanged(value: Float)
    func segmentSelected(index: Int)
    
}
