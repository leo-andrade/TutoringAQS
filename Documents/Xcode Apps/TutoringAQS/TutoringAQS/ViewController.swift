//
//  ViewController.swift
//  TutoringAQS
//
//  Created by Leonardo Andrade Osorio on 2/2/16.
//  Copyright © 2016 Leonardo Andrade Osorio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //arrays containing the values that will populate each of the PickerViews
    var tutoringCenters = ["ECF102", "ECG104", "CTRPT"]
    var tableNumbers = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"]
    //connection for the picker views
    @IBOutlet var centersPicker: UIPickerView!
    @IBOutlet var tablesPicker: UIPickerView!
    //variable for the TextField used on the UIAlertViewController
    var tField: UITextField!
    //variable to hold the server URL
    var serverURL = "https://"
    
    //function that executes if the view successfully loaded
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //Add the TapGesture Recognizer that will be used to change the server URL
        let tap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        tap.numberOfTapsRequired = 3
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //function to determine the number of components in the picker view and we have just 1 colum so using the same function for both pickerViews
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    //function to determine how many elements will each picker view have
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.viewWithTag(100) != nil){ //use the tag number to make reference to each picker view
            return tutoringCenters.count         //picker view 100 is the pickerView for the tutoring center locations
        }
        if (pickerView.viewWithTag(101) != nil){ //picker view 101 is the table number pickerView
            return tableNumbers.count
        }
        return 0
    }
    //function to populate each individual element in the picker view
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (pickerView.viewWithTag(100) != nil){
            return tutoringCenters[row]
        }
        if (pickerView.viewWithTag(101) != nil){
            return tableNumbers[row]
        }
        return nil
    }
    
    //function to pass the selected values to the next view
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToSubmitQuestion"){ //the segue to go to the SubmitQuestion View Controller is checked as the identifier
            let selectedCenter = tutoringCenters[centersPicker.selectedRowInComponent(0)] //save selected value from the centersPicker to be passed to the SubmitQuestion View Controller
            let selectedTable = tableNumbers[tablesPicker.selectedRowInComponent(0)] //save selected value from the tableNumbers to be passed to the SubmitQuestion View Controller
            let svc = segue.destinationViewController as! SubmitQuestionViewController
            svc.location = selectedCenter//pass the selected Center value to become the location
            svc.tableNum = selectedTable //pass the selected table number to become the tableNumber
            svc.baseURL = serverURL; //pass the server URL
        }
    }
    
    
    //function to handle doubleTap Gesture
    func doubleTapped()->Void{
        //create alert
        let alert = UIAlertController(title: "Change the server URL", message: "Please enter the new URL (no blank spaces)", preferredStyle: UIAlertControllerStyle.Alert)
        // add an action (button) and the textField to receive the data
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{(alert: UIAlertAction!) in self.changeServerURL()}))
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //function to take input from the UIAlertController used in the doubleTapped function to be used in changing the server URL
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Enter the url"
        tField = textField //take value and store it in tField
    }
    
    //function that will change the value of the serverURL variable and that is called from the UIAlert
    func changeServerURL(){
        serverURL = tField.text!;
    }

}

