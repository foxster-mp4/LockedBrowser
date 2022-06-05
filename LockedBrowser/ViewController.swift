//
//  ViewController.swift
//  LockedBrowser
//
//  Created by Huy Bui on 2021-09-06.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate { // Inherits from UIViewController, implements WKNaviagationDelegate protocol
    var webView: WKWebView! // Nullable but it won't be
    var progressView: UIProgressView!
    var websites: [String] = []
    var websiteToLoadIndex: Int!
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self // self (ViewController) is an instance of UIViewController but can be assigned to type WKNavigationDelegate since it conforms to the WKNavigationDelegate protocol

        view = webView // view is the root view of the view controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
//        edgesForExtendedLayout = [] // Attempting to stop the webView from getting stuck behind the navigation bar
        
        let url = URL(string: "https://www." + websites[websiteToLoadIndex!])
        
        webView.load(URLRequest(url: url!)) // webView loads URLRequests, not URLs
        webView.allowsBackForwardNavigationGestures = true // Allows swipping gestures to go back/forward (i.e. swipping from the left/right edges of the screen)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil) // Observing estimatedProgress property using KVO
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Websites", style: .plain, target: self, action: #selector(openButtonTapped))
        
        progressView = UIProgressView(progressViewStyle: .default)
        
        // MARK: Toolbar and buttons
        let progressBar = UIBarButtonItem(customView: progressView) // Wrapping progressView in a UIBarButtonItem to be able to add it to the toolbar
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // Flexible space will push the refresh button to the left (or right, depending on the order that they're added)
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(previousPage))
        let forwardButton = UIBarButtonItem(title: "Forward", style: .plain, target: self, action: #selector(nextPage))
        
        toolbarItems = [progressBar, flexibleSpace, backButton, forwardButton, refreshButton]
        navigationController?.isToolbarHidden = false // Required since toolbar is hidden by default?
    }
    
    @objc func openButtonTapped() {
        let alertController = UIAlertController(title: "Choose a website", message: nil, preferredStyle: .actionSheet)
        
        for website in websites { // Adding websites to the action sheet
            alertController.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel)) // Cancel button
        
        alertController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alertController, animated: true)
        
    }
    
    func openPage(action: UIAlertAction) {
        progressView.isHidden = false
        
        let url = URL(string: "https://" + action.title!)
        webView.load(URLRequest(url: url!))
    }
    
    // Page finished loading
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        
        // Hiding progress bar
        let delay = 0.25 // Delay in seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + delay){
            self.progressView.isHidden = true
        }
    }
    
    // Invoked when an observed value is changed
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress) // progressView's progress is a Float, so estimatedProgress (Double) must first be converted to a float before assigned
            
        }
    }
    
    // Monitoring navigations
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) { // An escaping closure is one that could be called straight away or later
        let url = navigationAction.request.url
        
        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return // Ends the method run
                }
            }
            
            // The code below will execute if the for loop completes and the function hasn't ended (aka host was not on the allowed websites list)
            let errorPopup = UIAlertController(title: "Unable to load page", message: "\(host) is not on the list of allowed websites", preferredStyle: .alert)
            errorPopup.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(errorPopup, animated: true)
        }
        
        decisionHandler(.cancel)
    }
    
    @objc func previousPage() {
        if webView.goBack() != nil {
            webView.goBack()
            progressView.isHidden = false
        }
    }
    
    @objc func nextPage() {
        if webView.goForward() != nil {
            webView.goForward()
            progressView.isHidden = false
        }
    }
}
