//
//  ViewController.swift
//  SearchGithub
//
//  Created by 康 on 2023/10/29.
//

import UIKit
import RxSwift

// 須解決第一個cell高度的問題
class MainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainTableView: MainTableView!
    @IBOutlet weak var repositoriesSearchLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var repositoriesSearchBar: UISearchBar!
    
    let viewModel = MainViewModel()
    let refreshController = UIRefreshControl()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        repositoriesSearchBar.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        viewModel.repositoriesObservable
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.mainTableView.reloadData()
                })
                .disposed(by: disposeBag)
        
        refreshController.addTarget(self, action: #selector(refreshData(_: )), for: .valueChanged)
        mainTableView.refreshControl = refreshController
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = repositoriesSearchBar.text, !query.isEmpty else { return }
        viewModel.searchRepo(query: query)
        searchBar.resignFirstResponder()
    }

    
    @objc func refreshData(_ sender: UIRefreshControl) {
        if let query = repositoriesSearchBar.text, query != "" {
            viewModel.searchRepo(query: query)
        } else {
            let alert = UIAlertController(title: "Oops", message: "The data couldn't be read because it is missing", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "ok", style: .cancel)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
            sender.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoriesCell", for: indexPath) as! RepositoryCell
        if let repository = viewModel.repositories?.items[indexPath.row] {
            cell.repositoriesTitleLabel.text = repository.name
            cell.repositoriesSubTitleLabel.text = repository.description
            
            if let urlString = repository.owner.avatar_url {
                viewModel.downloadImage(urlString: urlString)
                    .observe(on: MainScheduler.instance)
                    .subscribe { [weak cell] image in
                        cell?.repositoriesImageView.image = image
                    }
                    .disposed(by: disposeBag)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue",
           let detailVC = segue.destination as? DetailViewController,
           let indexPath = self.mainTableView.indexPathForSelectedRow {
            let selectedRepo = viewModel.repositories?.items[indexPath.row]
            detailVC.repository = selectedRepo
        }
    }
    
    
}

