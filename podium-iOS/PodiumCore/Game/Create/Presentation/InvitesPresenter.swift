//
//  InvitesPresenter.swift
//  podium-iOS
//
//  Created by Fernando Frances on 23/04/2018.
//  Copyright © 2018 Fernando Frances. All rights reserved.
//

import Foundation
import RxSwift
import Kingfisher

protocol InvitesView: class {
    func update(with users:[User])
}

final class InvitesPresenter {
    
    private let repository: CreateGameRepository
    private let disposeBag = DisposeBag()
    
    weak var view: InvitesView?
    
    init(repository: CreateGameRepository){
        self.repository = repository
    }
    
    func didLoad(){
        loadContents()
    }
    
    func loadContents() {
        repository.users()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] response in
                guard let `self` = self else {
                    return
                }
                self.view?.update(with: response.result)
                }, onError: { error in
                    print("Error downloading users")
                }, onDisposed: { [weak self] in
                    print("onDisposed")
            })
            .disposed(by: disposeBag)
    }
    
    func present(item: User, in cell: UserCell){
        cell.thumbnail.kf.setImage(with: URL(string:item.profilePic))
        cell.title.text = item.name
    }
}
