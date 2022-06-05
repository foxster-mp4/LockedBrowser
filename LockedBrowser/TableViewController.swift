//
//  TableViewController.swift
//  LockedBrowser
//
//  Created by Huy Bui on 2021-09-07.
//

import UIKit

class TableViewController: UITableViewController {
    var websites: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        websites += ["unsplash.com", "google.com", "hackingwithswift.com"]
        
        let projectDescription = UIBarButtonItem(title: "Practice Project 4 - Challenge 3", style: .plain, target: nil, action: nil)
        projectDescription.isEnabled = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [flexibleSpace, projectDescription, flexibleSpace]
        navigationController?.isToolbarHidden = false
        
        title = "LockedBrowser"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "viewController") as? ViewController {
            viewController.websites = self.websites
            viewController.websiteToLoadIndex = indexPath.row
            navigationController?.pushViewController(viewController, animated: true)
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
