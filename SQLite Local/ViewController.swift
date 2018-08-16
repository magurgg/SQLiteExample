//
//  ViewController.swift
//  SQLite Local
//
//  Created by Marco Antonio Gutierrez López on 3/10/18.
//  Copyright © 2018 Marco Antonio Gutierrez López. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPowerRanking: UITextField!
    var heroList = [Hero]()
    var db: OpaquePointer?
    @IBOutlet weak var tableViewHeroes: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Arhivo de DB
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        
        //Abriendo DB
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //Creando tabla
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func buttonSave(_ sender: UIButton) {
        //Obteniendo los textos de los textField
        let name = textFieldName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let powerRanking = textFieldPowerRanking.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //Validar que no estén vacios
        if(name?.isEmpty)!{
            textFieldName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(powerRanking?.isEmpty)!{
            textFieldName.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        //Creando statement
        var stmt: OpaquePointer?
        
        //Query para insertar
        let queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        //Prarando el query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //Añadiendo parámetros
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (powerRanking! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //Ejecutar el query par insertar
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        textFieldName.text=""
        textFieldPowerRanking.text=""
        readValues()
        print("Herro saved successfully")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        readValues()
    }
    
    func readValues(){
        
        //Vaciar lista de héroes
        heroList.removeAll()
        
        //Query de SELECT
        let queryString = "SELECT * FROM Heroes"
        
        //Statement pointer
        var stmt:OpaquePointer?
        
        //Prearando el query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //Leyendo registros
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            //Añandiendo a la lista
            heroList.append(Hero(id: Int(id), name: String(describing: name), powerRanking: Int(powerrank)))
        }
        self.tableViewHeroes.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //this method is giving the row count of table view which is
        //total number of heroes in the list
        return heroList.count
    }
    
    //this method is binding the hero name with the tableview cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        let hero: Hero
        hero = heroList[indexPath.row]
        cell.textLabel?.text = hero.name
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

