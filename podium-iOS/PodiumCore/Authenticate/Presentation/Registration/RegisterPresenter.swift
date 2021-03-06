//
//  EmailNewUserPresenter.swift
//  podium-iOS
//
//  Created by Fernando Frances on 30/03/2018.
//  Copyright © 2018 Fernando Frances. All rights reserved.
//

import RxSwift

protocol RegisterView : class {
    var title: String? { get set }
    func update(with sections: [RegisterSection])
    func updateSection(with items: [ThumbItem])
    func dismissAll()
}


final class RegisterPresenter {
    private let repository: AuthenticationRepositoryProtocol
    private let magicLinkNavigator: MagicLinkNavigator
    private let registerType: RegisterType
    private let email: String?
    
    var sportsIdentifiers = [String]()
    let disposeBag = DisposeBag()
    
    weak var view: RegisterView?
    
    init(repository: AuthenticationRepositoryProtocol, magicLinkNavigator: MagicLinkNavigator, type: RegisterType, email: String?){
        self.repository = repository
        self.magicLinkNavigator = magicLinkNavigator
        self.registerType = type
        self.email = email ?? ""
    }
    
    func didLoad() {
        self.view?.update(with: self.registerSections())
        loadSports()
    }
    
    func loadSports() {
        repository.sports()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] response in
                guard let `self` = self else {
                    return
                }
                let items = response.result.map { ThumbItem(sport: $0) }
                self.view?.updateSection(with: items)
                }, onError: { error in
                    print("Email downloading sports")
                }, onDisposed: { [weak self] in
                    print("onDisposed")
                })
            .disposed(by: disposeBag)
    }
    
    private func registerSections() -> [RegisterSection] {
        var registerSections : [RegisterSection] = [
            .field(type: .alias),
            .thumbView(title: NSLocalizedString("What sports do you practice?", comment: ""), items:[]),
            .submit(title: "Sign up!")
        ]
        if registerType == .email{
            registerSections.insert(.field(type: .name), at: 0)
        }
        return registerSections
    }
    
    func submit(withUserData data: [String : String]) {
        var userData = data
        userData["email"] = email
        userData["sports"] = sportsIdentifiers.joined(separator: ",")
        switch registerType {
        case .email:
            emailRegisterRequest(with: userData)
        case .social:
            socialRegisterRequest(with: userData)
        }
        
    }
    
    private func emailRegisterRequest(with userData: [String:String]) {
        repository.emailRegister(data: userData)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] response in
                guard let `self` = self else {
                    return
                }
                if response.auth {
                    self.magicLinkNavigator.showMagicLinkViewController()
                }
                }, onError: { error in
                    print("Email register error: \(error)")
            }, onDisposed: { [weak self] in
                print("onDisposed")
            })
            .disposed(by: disposeBag)
    }
    
    private func socialRegisterRequest(with userData: [String: String]) {
        repository.socialRegister(data: userData)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: {[weak self] response in
                    guard let `self` = self else {
                        return
                    }
                    self.view?.dismissAll()
                    }, onError: { error in
                        print("Email register error: \(error)")
                }, onDisposed: { [weak self] in
                    print("onDisposed")
                })
                .disposed(by: disposeBag)
    }
    
    
}
