//
//  AuthViewController.swift
//  CP
//
//  Created by Arnaud Verrier on 11/12/2016.
//  Copyright © 2016 Arnaud Verrier. All rights reserved.
//

import Foundation
import UIKit

protocol AuthViewControllerProtocol {
    func acceptAuth()
    func rejectAuth()
}

class AuthViewController: UIViewController {
    
    var delegate:AuthViewControllerProtocol?
    var authType = AuthType.none
    
    @IBOutlet weak var lblAuth: UILabel!
    
    @IBOutlet weak var btnNook: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    
    @IBAction func btnNookPressed(_ sender: Any) {
        self.delegate?.rejectAuth()
    }
    @IBAction func btnOkPressed(_ sender: Any) {
        self.delegate?.acceptAuth()
    }
    
    convenience init(authType:AuthType) {
        
        self.init(nibName: "AuthViewController", bundle: nil)
        self.authType = authType
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        popUpStyle(view: lblAuth)
        popUpStyle(view: btnNook)
        popUpStyle(view: btnOk)
        
        switch authType {
        case .location:
            lblAuth.text = "Afin de vous repérer sur la carte nous avons besoin d'avoir accès à votre localisation"
        default:
            print("Cas général")
        }
    }
    
    func popUpStyle(view:UIView) {
        
        if let label = view as? UILabel {
            label.textColor = .white
        }
        
        if let btn = view as? UIButton {
            btn.setTitleColor(.white, for: .normal)
            btn.layer.borderColor = UIColor.white.cgColor
            btn.layer.borderWidth = 0.5
            btn.layer.cornerRadius = 15
        }
    }
}
