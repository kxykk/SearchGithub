//
//  RepositoryCell.swift
//  SearchGithub
//
//  Created by 康 on 2023/10/30.
//

import UIKit

class RepositoryCell: UITableViewCell {

    @IBOutlet weak var repositoriesImageView: UIImageView!
    @IBOutlet weak var repositoriesSubTitleLabel: UILabel!
    @IBOutlet weak var repositoriesTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        repositoriesImageView.image = nil
        repositoriesTitleLabel.text = nil
        repositoriesSubTitleLabel.text = nil
    }

}
