//
//  ChooseSportPresenter.swift
//  podium-iOS
//
//  Created by Fernando Frances on 22/04/2018.
//  Copyright © 2018 Fernando Frances. All rights reserved.
//

import Foundation
import RxSwift

protocol ChooseSportView: class {
    func update(with sports: [Sport])
}

final class ChooseSportPresenter {
    
    private let repository: CreateGameRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    weak var view: ChooseSportView?
    
    init(repository: CreateGameRepositoryProtocol){
        self.repository = repository
    }
    
    func didLoad () {
        loadContents()
    }
    
    func loadContents() {
        repository.sports()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] response in
                guard let `self` = self else {
                    return
                }
                    self.view?.update(with: response.result)
                }, onError: { error in
                    print("Error downloading sports")
                }, onDisposed: { [weak self] in
                    print("onDisposed")
                })
            .disposed(by: disposeBag)
    }
}
