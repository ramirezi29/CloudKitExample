//
//  ListTVCell.swift
//  VIPList
//
//  Created by Ivan Ramirez on 4/12/22.
//

import UIKit

class ListTVCell: UITableViewCell {
    
    //landing pad
    var exercise: Exercise?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var contentConfig = defaultContentConfiguration().updated(for: state)
        
        guard let exercise = exercise else {
            return
        }
        
        contentConfig.text = exercise.name
        contentConfig.secondaryText = exercise.minuteCount
        contentConfig.secondaryTextProperties.color = .secondaryLabel
        contentConfig.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentConfig.imageToTextPadding = 12
        contentConfig.textToSecondaryTextVerticalPadding = 8
        contentConfig.textToSecondaryTextHorizontalPadding = 8
        
        contentConfig.image = UIImage(systemName: "bolt")
        contentConfig.imageProperties.maximumSize =  CGSize(width: 100, height: 100)
        
        contentConfiguration = contentConfig
        
    }
}
