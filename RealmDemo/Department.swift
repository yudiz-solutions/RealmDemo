//
//  Department.swift
//  
//
//  Created by Yudiz on 12/20/16.
//
//

import Foundation
import RealmSwift

class Department: Object{
    dynamic var id: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var startDate: NSDate?
//    let employees = List<Employee>()
    var employees = LinkingObjects(fromType: Employee.self, property: "dept")
    
    var noOfEmployee : Int{
        return employees.count
    }
    
    override open class func primaryKey() -> String?{
        return "id"
    }
}
