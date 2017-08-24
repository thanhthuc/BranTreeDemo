//
//  ViewController.swift
//  BranTreeDemo
//
//  Created by iOS Developer on 8/8/17.
//  Copyright © 2017 Nguyen Thanh Thuc. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn


class ViewController: UIViewController {

    @IBOutlet weak var paymentIcon: UIView!
    @IBOutlet weak var paymentMethod: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var optiontypeLable: UILabel!
    
//    var brainTree: BT?
    
    let btNetworkClient = NetworkClient.sharedInstance
    var clientToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchClientToken()
                
        self.paymentIcon.backgroundColor = UIColor.orange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showDropIn(_ sender: UIButton) {
       showDropIn_(clientTokenOrTokenizationKey: clientToken!)
    }
    
    @IBAction func proccessingWithCard(_ sender: Any) {
        setUpPaymentProccessing()
    }
    
    
    func showDropIn_(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.applePayDisabled = false
        
        request.threeDSecureVerification = true
        request.amount = "1.00"
        
        // Set the theme before initializing Drop-in
        BTUIKAppearance.darkTheme()
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("USER CANCELLED")
            } else if let result = result {
                
                // Use the BTDropInResult properties to update your UI
                self.paymentIcon = result.paymentIcon
                
                if let paymentMethod = result.paymentMethod {
                    self.paymentMethod.text = "payment method nonce: \(paymentMethod.nonce)"
                    self.makeTransaction(paymentMethodNonce: paymentMethod.nonce)
                }
                
                self.descriptionLabel.text = "payment description: \(result.paymentDescription)"
                self.optiontypeLable.text = "payment option type: \(result.paymentOptionType.rawValue)"
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    
    func fetchExistingPaymentMethod(clientToken: String) {
        BTDropInResult.fetch(forAuthorization: clientToken) { (result, error) in
            if (error != nil) {
                print("ERROR")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                self.paymentIcon = result.paymentIcon
                
                if let paymentMethod = result.paymentMethod {
                    self.paymentMethod.text = "payment method nonce: \(paymentMethod.nonce)"
                }

                self.descriptionLabel.text = "payment description: \(result.paymentDescription)"
                self.optiontypeLable.text = "payment option type: \(result.paymentOptionType.rawValue)"

            }
        }
    }
    
    
    func setUpPaymentProccessing() {
        // For client authorization,
        // get your tokenization key from the Control Panel
        // or fetch a client token
        let braintreeClient = BTAPIClient(authorization: clientToken!)!
        let cardClient = BTCardClient(apiClient: braintreeClient)
        let card = BTCard(number: "4111111111111111", expirationMonth: "12", expirationYear: "2018", cvv: nil)
        cardClient.tokenizeCard(card) { (tokenizedCard, error) in
            // Communicate the tokenizedCard.nonce to your server, or handle error
            
            if let error = error {
                print(error)
            } else if let tokenize = tokenizedCard {
                print(tokenize)
            }
        }
    }
}


// MARK: API request

extension ViewController {
    
    func fetchClientToken() {
        // TODO: Switch this URL to your own authenticated API
        let clientTokenURL = BTAPIEndPoint.getClientToken.url
        
        let request = NSMutableURLRequest(url: clientTokenURL!)
        request.httpMethod = BTAPIEndPoint.getClientToken.httpMethod
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        btNetworkClient.sendRequest(request: request as URLRequest) { (data, respond, error) in
            if let error = error {
                print(error)
            } else if let data = data {
                let clientToken = String(data: data, encoding: .utf8)
                self.clientToken = clientToken
                print("success get client token: \(clientToken!)")
            }
        }
    }
    
    func makeTransaction(paymentMethodNonce: String) {
        
        let paymentURL = BTAPIEndPoint.checkout.url
        
        var request = URLRequest(url: paymentURL!)
        
        request.httpMethod = BTAPIEndPoint.checkout.httpMethod 
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // MARK: Custom more info here
        
        let bodyData = "payment_method_nonce=\(paymentMethodNonce)&amount=15"
        
        request.httpBody = bodyData.data(using: .utf8)
        
        btNetworkClient.sendRequest(request: request) { (data, response, error) in
            
            let response = response as? HTTPURLResponse
            if let response = response {
                
                print(response.statusCode)
                guard response.statusCode == 200 else {
                    print("request not found")
                    return
                }
                
                if let error = error {
                    print(error)
                } else if let data = data {
                    do {
                        let dict = try JSONSerialization.jsonObject(with: data, options: [])
                        print("Success transaction with data: \(dict)")
                    }catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    

    
}
