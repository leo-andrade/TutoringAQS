//
//  SubmitQuestionViewController.swift
//  TutoringAQS
//
//  Created by Leonardo Andrade Osorio on 2/2/16.
//  Copyright © 2016 Leonardo Andrade Osorio. All rights reserved.
//

import UIKit
import Foundation

class SubmitQuestionViewController: UIViewController {
    //textFields and labels from the view controller
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var tableLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var asuIDtextField: UITextField!
    @IBOutlet var courseNotListedTextField: UITextField!
    @IBOutlet var courseNotListedLabel: UILabel!
    @IBOutlet var courseNotListedLabel2: UILabel!
    //pickerView
    @IBOutlet var coursesPicker: UIPickerView!
    //variable declaration
    var courses = [String]()
    var location: String = "None"
    var tableNum: String = "None"
    var selectedCourse: String = "None"
    var studentName: String = "None"
    var asuID: String = "None"
    var otherCourse: String = "None"
    //variable to check if the OTHER course was selected
    var otherSelected: Bool = false
    //variable for TextField in UIAlertViewController
    var tField: UITextField!
    var baseURL: String = "None"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationLabel.text = "You're currently at the \(location) Tutoring Center"
        tableLabel.text = "You're currently at table #\(tableNum)"
        
        //code to dismiss keyboard if the screen is tapped anywhere
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        //fetch Courses info from website
        let CoursesURL: String = baseURL + "remote/queue/courselist/" + location
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: CoursesURL)!
        
        //perform call to the API to fetch course list depending on which Tutoring Center was chosen
        session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    //create an alert to let the user know that the request to fetch the list of courses failed
                    let errorAlert = UIAlertController(title: "Error", message: "Connection error while retrieving course list. Please go to previous screen and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                     self.courses.append("ASU101")
                    //reload the elements in the pickerView using a different thread to not disrupt the auto layout
                    dispatch_async(dispatch_get_main_queue(), {
                        self.coursesPicker.reloadAllComponents()
                    })
                    print("Got a bad response")
                    return
            }
            // Read the array of courses and process to be displayed properly
            do {
                if let coursesString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    // Print what we got from the call
                    //print(coursesString)
                    //get rid of unwanted characters from conversion
                    let newString = coursesString.stringByReplacingOccurrencesOfString("&#034;", withString: "")
                    //print(newString)
                    //create an array of Strings that contain all of the courses
                    let coursesArray = [String](newString.componentsSeparatedByString(","))
                    self.courses.appendContentsOf(coursesArray)
                    //remove unwanted element from first index
                    self.courses.removeAtIndex(0)
                    //remove unwanted characters from last element in array
                    let lastElement = self.courses.last?.stringByReplacingOccurrencesOfString("\n", withString: "")
                    //replace the correct last element back into the array
                    self.courses.removeLast()
                    self.courses.append(lastElement!)
                    self.courses.append("OTHER")
                    //reload the elements in the pickerView using a different thread to not disrupt the auto layout
                    dispatch_async(dispatch_get_main_queue(), {
                       self.coursesPicker.reloadAllComponents()  
                    })
                }
            }
        }).resume()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //the next 3 functions are for populating the UIPickerView with data from the Courses array
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return courses.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return courses[row]
    }
    
    //function to dismiss keyboard when the screen is tapped
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    //function to check the current value of the pickerview
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
    {
        // selected value in Uipickerview
        let value=self.courses[row]
        if (value == "OTHER"){ //if OTHER is selected from the pickerView then the extra TextField and label will be showed
            self.otherSelected = true
            self.courseNotListedLabel.hidden = false
            self.courseNotListedTextField.hidden = false
            self.courseNotListedLabel2.hidden = false;
        }
        else{ //if OTHER is not selected from the pickerView then the extra TextField and labels will be hidden
            self.otherSelected = false
            self.courseNotListedLabel.hidden = true
            self.courseNotListedTextField.hidden = true
            self.courseNotListedLabel2.hidden = true;
        }
        //set selectedCourse to the currently selected course in the UIPickerView
        self.selectedCourse = self.courses[row]
    }

    //function that determines if the button was pressed to submit a question
    @IBAction func submitPressed(sender: AnyObject) {
        //check that data fields have data with a listed course from the UIPickerView
        let strID = self.asuIDtextField.text; //string to check the length of StudentID string
        if((self.nameTextField.text != "" && strID?.characters.count == 10 && !self.otherSelected) || (self.otherSelected && self.nameTextField.text != "" && strID?.characters.count == 10 && self.courseNotListedTextField.text != "")){
            // create the alert
            let alert = UIAlertController(title: "Confirmation", message: "You're submitting a question. Only submit one question per student at a time.", preferredStyle: UIAlertControllerStyle.Alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler:{(alert: UIAlertAction!) in self.sendQuestion()}))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
        }else { //else for when the fields are not correctly filled out
            let errorAlert = UIAlertController(title: "Error", message: "One or more of the fields are incomplete or have incorrect data", preferredStyle: UIAlertControllerStyle.Alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(errorAlert, animated: true, completion: nil)
        }
        
    }
    
    //function to send question to queue
    func sendQuestion(){
        self.studentName = checkString(self.nameTextField.text!);
        self.asuID = checkString(self.asuIDtextField.text!);
        var queueURL:String = baseURL + "remote/queue/";
        //The format to submit a question to the System is the following
        //remote/queue/{name}/{studentID}/{course}/{table}/{center}
        if (self.location == "CTRPT"){
            self.location = "CTRPT114"}
        //check if OTHER course is being submitted
        if (!otherSelected){
            queueURL = queueURL + self.studentName + "/" + self.asuID + "/" + self.selectedCourse + "/" + self.tableNum + "/" + self.location
        }else {
            self.otherCourse = checkString(self.courseNotListedTextField.text!)
            queueURL = queueURL + self.studentName + "/" + self.asuID + "/" + self.otherCourse + "/" + self.tableNum + "/" + self.location
        }
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: queueURL)!
        //perform call to the API
        session.dataTaskWithURL(url, completionHandler: { (data: NSData?, response: NSURLResponse?, error:NSError?) -> Void in
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    //code to generate the alert is inside of dispat_async to not change the layout of the View Controller from a background thread
                    dispatch_async(dispatch_get_main_queue(), {
                        //create alert
                        let alert = UIAlertController(title: "Submission Failed", message: "Your question was not submitted succesfully. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        // show the alert
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                    print("Got a bad response")
                    return
            }
            
            do {
                //code to generate the alert is inside of dispat_async to not change the layout of the View Controller from a background thread
                dispatch_async(dispatch_get_main_queue(), {
                    //create alert
                    let alert = UIAlertController(title: "Sucessful Submission", message: "Your question was submitted succesfully!", preferredStyle: UIAlertControllerStyle.Alert)
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    // show the alert
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                print("Question was posted")
            }
        }).resume()
        //clear textFields
        self.nameTextField.text = ""
        self.asuIDtextField.text = ""
        self.courseNotListedTextField.text = ""
    }

    //function to check the value entered to go back to the Set Up iPad View Controller
    func checkPin(){
        if (tField.text == "1966"){ //compare tField with the hardcoded value to give access to the set up iPad View Controller
            performSegueWithIdentifier("segueToMainViewController", sender: nil)
        }
        else { //display an alert displaying that the PIN entered was incorrect
            //create alert
            let alert = UIAlertController(title: "Error", message: "Incorrect PIN number was entered", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //function to check that the string has not empty spaces or invalid characters that will generate an invalid URL
    func checkString(str: String)->String{
        print("String received \(str)")
        var newStr = str.stringByReplacingOccurrencesOfString(" ", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("+", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("*", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString("(", withString: "")
        newStr = newStr.stringByReplacingOccurrencesOfString(")", withString: "")
        print("\nString changed \(newStr)")
        return newStr
    }
    
    //function to take input from the UIAlertController used in the resetPressed function to be used in the checkPin funciton
    func configurationTextField(textField: UITextField!){
        textField.placeholder = "Enter an item"
        tField = textField //take value and store it in tField
    }
    
    //function to determine if the resetButton was pressed
    @IBAction func resetPressed(sender: AnyObject) {
        //create alert
        let alert = UIAlertController(title: "Navigation to Set Page", message: "Please enter PIN number to proceed", preferredStyle: UIAlertControllerStyle.Alert)
        // add an action (button)
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.checkPin()}))
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}
