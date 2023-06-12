//
//  TodosVM.swift
//  TodoAppTutorial
//
//  Created by Jeff Jeong on 2022/11/20.
//

import Foundation
import Combine
class InfoVM: ObservableObject {
    
    init(){
        print(#fileID, #function, #line, "- ")
        
//        UserInfoAPI.addATodo(title: "빡코딩중이야~~~",
//                              isDone: true,
//                              completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM addATodo - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
        UserInfoAPI.fetchAData( completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let aTodoResponse):
                print("TodosVM addATodo - aTodoResponse: \(aTodoResponse)")
            case .failure(let failure):
                print("TodosVM addATodo - failure: \(failure)")
                self.handleError(failure)
            }
        })
        
        
        
//        TodosAPI.searchTodos(searchTerm: "빡코딩") { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - search todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }//
        
//        TodosAPI.fetchATodo(id: 1550, completion: { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let aTodoResponse):
//                print("TodosVM - aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.fetchTodos { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let todosResponse):
//                print("TodosVM - todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print("TodosVM - failure: \(failure)")
//                self.handleError(failure)
//            }
//        }//
    }// init
    
    
    
    /// API 에러처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is UserInfoAPI.ApiError {
            let apiError = err as! UserInfoAPI.ApiError
            
            print("handleError : err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음")
            case .unauthorized:
                print("인증안됨")
            default:
                print("default")
            }
        }
        
    }// handleError
    
}
