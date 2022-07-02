//
//  ListTVC.swift
//  VIPList
//
//  Created by Ivan Ramirez on 4/12/22.
//

import UIKit

class ListTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ExerciseController.shared.exercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as? ListTVCell else {
            return UITableViewCell()
        }
        
        let exercise = ExerciseController.shared.exercises[indexPath.row]
        
        cell.exercise = exercise
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toDelete = ExerciseController.shared.exercises[indexPath.row]
            guard let index = ExerciseController.shared.exercises.firstIndex(of: toDelete) else { return }
            
            ExerciseController.shared.delete(toDelete) { success in
                if success {
                    ExerciseController.shared.exercises.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = .white
        }
    }
    
    func saveOption() {
        var nameTextField: UITextField?
        var lengthTextField: UITextField?
        
        let exerciseAlert = AlertController.presentAlertControllerWith(alertTitle: "Exercise Details", alertMessage: "Enter in the description", dismissActionTitle: "Cancel")
        
        //1
        exerciseAlert.addTextField { itemName in
            itemName.placeholder = "Enter Name"
            nameTextField = itemName
        }
        //2
        exerciseAlert.addTextField { length in
            length.placeholder = "Enter Length"
            lengthTextField = length
        }
        
        // SAVE :D
        let saveToCKDatabase = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let name = nameTextField?.text, !name.isEmpty, let length = lengthTextField?.text else {
                return
            }
            
            ExerciseController.shared.saveExercise(with: name, minuteCount: length) { success in
                
                if success {
                    print("\nSuccessfully saved new Exercise\n")
                    
                    //NOTE: - The .asynchAfter is a work around I found to account for the slight delay caused by Cloudkit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.loadData()
                    }
                }
            }
        }
        // add the save action to our alert controller
        exerciseAlert.addAction(saveToCKDatabase)
        
        //we need to present the alert we just defined above
        DispatchQueue.main.async {
            self.present(exerciseAlert, animated: true, completion: nil)
        }
    }
    
    func loadData() {
        print("Load data function called")
        ExerciseController.shared.fetchExercise { result in
            switch result {
            case .success(let exercise):
                ExerciseController.shared.exercises = exercise ?? []
                
                //NOTE: - Try removing the DispatchQueue.main.async, you may get an error from Xcode where this table reload data has to be called on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        saveOption()
    }
}
