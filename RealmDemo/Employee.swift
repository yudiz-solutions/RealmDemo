//
//  Employee.swift
//  RealmDemo
//
//  Created by Yudiz on 12/20/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import UIKit
import RealmSwift

class Employee: Object{
    dynamic var id: String = UUID().uuidString
    dynamic var name: String = ""
    dynamic var dept: Department?
//    let depts = LinkingObjects(fromType: Department.self, property: "employees")
}
