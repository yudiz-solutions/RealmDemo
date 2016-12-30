//
//  EmployeeVC.swift
//  RealmDemo
//
//  Created by Yudiz on 12/20/16.
//  Copyright © 2016 Yudiz. All rights reserved.
//

import UIKit
import RealmSwift

class EmployeeVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var dept: Department!
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = dept.name
        addObserverOnEmployees()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        token?.stop()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Observer of results
extension EmployeeVC{
    func addObserverOnEmployees(){
        token = dept.employees.addNotificationBlock({ [weak self] (collectionChange) in
            switch collectionChange{
            case .initial(_):
                self?.tableView.reloadData()
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


// MARK: - Actions
extension EmployeeVC{
    
    @IBAction func addEmpolyee(sender: UIButton){
        let alert = UIAlertController.init(title: "", message: "Enter Employee name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: nil)
        let add = UIAlertAction(title: "Add", style: UIAlertActionStyle.default) { (action) in
            if !(alert.textFields?[0].text?.isEmpty)!{
                self.addEmployee(name: alert.textFields![0].text!)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Tableview
extension EmployeeVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dept.employees.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = dept.employees[indexPath.row].name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit") { (action, index) in
            tableView.setEditing(false, animated: true)
            self.editEmployee(emp: self.dept.employees[index.row])
        }
        edit.backgroundColor = UIColor.darkGray
        
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete") { (action, index) in
            self.deleteEmployee(emp: self.dept.employees[index.row])
        }
        return [edit, delete]
    }
}

// MARK: - Realm Add, Update methods
extension EmployeeVC{
    
    func addEmployee(name: String){
        let relm = try! Realm()
        let emp = Employee(value: ["name": name, "dept": dept])
        try! relm.write {
            relm.add(emp)
        }
    }
    
    func deleteEmployee(emp: Employee){
        let relm = try! Realm()
        try! relm.write {
            relm.delete(emp)
        }
    }

    func editEmployee(emp: Employee){
        let alert = UIAlertController.init(title: "", message: "Edit Employee name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: { (tf) in
            tf.text = emp.name
        })
        
        let add = UIAlertAction(title: "Update", style: UIAlertActionStyle.default) { (action) in
            if !(alert.textFields?[0].text?.isEmpty)!{
                let relm = try! Realm()
                try! relm.write {
                    emp.name = alert.textFields![0].text!
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}
