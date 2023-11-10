//
//  DetailViewController.swift
//  SearchGithub
//
//  Created by 康 on 2023/11/7.
//

import UIKit
import RxSwift

class DetailViewController: UIViewController {
    
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoImageView: UIImageView!
    @IBOutlet weak var repoFullName: UILabel!
    @IBOutlet weak var repoLanguage: UILabel!
    @IBOutlet weak var repostars: UILabel!
    @IBOutlet weak var repoWatchers: UILabel!
    @IBOutlet weak var repoForks: UILabel!
    @IBOutlet weak var repoOpenIssue: UILabel!
    
    var repository: Repository?
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let name = repository?.name {
            repoName.text = name
        }
        
        if let fullName = repository?.full_name {
            repoFullName.text = fullName
        }
        
        if let language = repository?.language {
            repoLanguage.text = "written in \(language)"
        } else {
            repoLanguage.text = "Language not specified"
        }
        
        if let stars = repository?.stargazers_count {
            repostars.text = "\(stars) stars"
        } else {
            repostars.text = "0 stars"
        }
        
        if let watchers = repository?.watchers_count {
            repoWatchers.text = "\(watchers) watchers"
        } else {
            repoWatchers.text = "0 watchers"
        }
        
        if let forks = repository?.forks_count {
            repoForks.text = "\(forks) forks"
        } else {
            repoForks.text = "0 forks"
        }
        
        if let openIssues = repository?.open_issues_count {
            repoOpenIssue.text = "\(openIssues) open issues"
        } else {
            repoOpenIssue.text = "0 open issues"
        }
        
        if let urlString = repository?.owner.avatar_url {
            viewModel.downloadImage(urlString: urlString)
                .observe(on: MainScheduler.instance)
                .subscribe { [weak self] image in
                    self?.repoImageView.image = image
                }
                .disposed(by: disposeBag)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
