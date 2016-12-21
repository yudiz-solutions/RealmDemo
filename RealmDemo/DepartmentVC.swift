//
//  DepartmentVC.swift
//  RealmDemo
//
//  Created by Yudiz on 12/20/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import UIKit
import RealmSwift

class DepartmentVC: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var depts : Results<Department>!
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let relm = try! Realm()
        depts = relm.objects(Department.self)
    
        addObserverOnDepats()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        token?.stop()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "employeeSegue"{
            let dest = segue.destination as! EmployeeVC
            dest.dept = sender as! Department
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}


// MARK: - Observer of results
extension DepartmentVC{
    func addObserverOnDepats(){
        token = depts.addNotificationBlock({ [weak self] (collectionChange) in
            switch collectionChange{
            case .initial(_):
               self?.tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.automatic)
                break;
            case .update(_, let delIdx, let insrtIdx, let modiIdx):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insrtIdx.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.automatic)
                self?.tableView.deleteRows(at: delIdx.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.automatic)
                self?.tableView.reloadRows(at: modiIdx.map({IndexPath(row: $0, section: 0)}), with: UITableViewRowAnimation.automatic)
                self?.tableView.endUpdates()
                break;
            case .error(let error):
                print(error)
                break
            }
        })
    }
}

// MARK: - Action
extension DepartmentVC{

    @IBAction func addDepartment(sender: UIButton){
        let alert = UIAlertController.init(title: "", message: "Enter Department name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)
        let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action) in
            if !(alert.textFields?[0].text?.isEmpty)!{
                self.addDepartment(name: alert.textFields![0].text!)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
    
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sortDepartment(sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let byName = UIAlertAction(title: "Sort By Name", style: UIAlertActionStyle.default) { (action) in
            self.sortDeptByName()
        }
        
        let byStartDate = UIAlertAction(title: "Sort By Start Date", style: UIAlertActionStyle.default) { (action) in
            self.sortByStartDate()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        alert.addAction(byName)
        alert.addAction(byStartDate)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Tableview methods
extension DepartmentVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return depts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = depts[indexPath.row].name
        cell?.detailTextLabel?.text = "Number of employee: \(depts[indexPath.row].noOfEmployee)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action, index) in
            self.tableView.setEditing(false, animated: true)
            self.editDepartment(dept: self.depts[index.row])
        }
        edit.backgroundColor = UIColor.darkGray
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action, index) in
            self.deleteDepartment(dept: self.depts[index.row])
        }
        return [edit, delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "employeeSegue", sender: depts[indexPath.row])
    }
}


// MARK: - Realm Add, Update methods
extension DepartmentVC{
    
    func addDepartment(name: String){
        let relm = try! Realm()
        let dept = Department(value: ["name":name, "startDate" : Date()])
        try! relm.write {
            relm.add(dept)
        }
    }

    func deleteDepartment(dept: Department){
        let relm = try! Realm()
        try! relm.write {
            // Delete all employee from this department bcz. Realm do not have any delation rule like. (cascade delete)
            relm.delete(dept.employees)
            relm.delete(dept)
        }
    }
    
    func editDepartment(dept: Department){
        let alert = UIAlertController.init(title: "", message: "Edit Department name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (tf) in
            tf.text = dept.name
        })
        
        let add = UIAlertAction(title: "Update", style: UIAlertActionStyle.default) { (action) in
            if !(alert.textFields?[0].text?.isEmpty)!{
                let relm = try! Realm()
                try! relm.write {
                    dept.name = alert.textFields![0].text!
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func sortDeptByName(){
        depts = depts.sorted(byProperty: "name", ascending: true)
        addObserverOnDepats()
    }
    
    func sortByStartDate(){
        depts = depts.sorted(byProperty: "startDate", ascending: true)
        addObserverOnDepats()
    }
}
