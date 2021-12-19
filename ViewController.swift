//
//  ViewController.swift
//  Swift_App
//
//  IMPORTANT: 
//  FILE: ViewController.swift
//  Line 60: Replace and use the API Key registered at https://www.spoonacular.com 

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var recipeType: UILabel!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeImageView: UIImageView?
    @IBOutlet weak var recipeNumber: UILabel!
    
    enum DirectionType {
        case Next
        case Previous
    }
    
    @IBAction func recipeNextButton(_ sender: UIButton) {
        let dir = DirectionType.Next
        self.recipesIndexUpdate(direction: dir)
    }
       
    @IBAction func recipePreviousButton(_ sender: UIButton) {
        let dir = DirectionType.Previous
        self.recipesIndexUpdate(direction: dir)
    }
    
    var recipes = [Recipe]()
    var recipesIndex = 0
    
    let httpResponseOK: Int = 200
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // called once after recipe fetched successfully
    func recipeIndexInit() {
        if self.recipesIndex == 0 {
            self.recipesIndex = 1
        }
    }
    
    // Function: fetchRecipeData()
    // Send recipe request with Spoonacular REST API website
    // 1. Register your API Key at Spponacular website: https://www.spoonacular.com
    // 2. Url query string: 'apiKey' Use your registered API Key (32 Letters) in the string: apiKey="xxx"
    // 3. Url query string: 'query' The Type (String) of recipe
    // 4. Url query string: 'offset' The number of results to skip (between 0 and 900), default is '0'
    // 5. Url query string: 'number' The number of expected results (between 1 and 100), default is '10'
    func fetchRecipeData(completion: @escaping (Result<[Recipe], Error>) -> Void) {
        
        // Default query Type "Vegan" recipes (append query string number=15 to fetch 100 results)
        let url = URL(string: "https://api.spoonacular.com/recipes/complexSearch?apiKey=[YOUR_API_KEY_HERE]&?&query=vegan&offset=0&number=100")!
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
                if let taskError = error {
                    print("Task error: \(taskError)")
                    self.sendAlertMessage()
                } else {
                    let resp = response as! HTTPURLResponse
                    switch resp.statusCode {
                        case self.httpResponseOK:
                            let fetchResult = self.parseRecipeJson(data: data! as NSData, error: error)
                            OperationQueue.main.addOperation {
                                completion(fetchResult)
                            }
                        default:
                            print("Error HTTP Response Status Code \(resp.statusCode)")
                            self.sendAlertMessage()
                    }
                }
        }
        task.resume()
    }
    
    // Function: parseRecipeJson()
    // Parse the recipe response from Spoonacular REST API website
    // by using JSONSerialization API call to unwrap JSON Object
    func parseRecipeJson(data: NSData, error: Error?) -> Result<[Recipe], Error> {
        let dataString = String(data: data as Data, encoding: .utf8)
        print("RecipeJsonDataString=\(String(describing: dataString))")
        
        do {
            let recipeJson: AnyObject? = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as AnyObject?
            if let unwrapJson: AnyObject = recipeJson {
                parseRecipe(json: unwrapJson)
            }
        } catch {
            print("Error parsing recipe")
            self.sendAlertMessage()
            return .failure(error)
        }
        return .success(recipes)
    }
    
    /*
     Recipe response data (JSON format)
     {
     results:
     [{id, title, image, imageType}*],
     offset, number, totalResults
     }
     */
    func parseRecipe(json: AnyObject) {
        if let results = json["results"] as? [[String: AnyObject]] {
            for recipesJson in results {
                if let title = recipesJson["title"] as? String {
                    if let imageUrl = recipesJson["image"] as? String {
                        let recipe = Recipe(title: title, imageUrl: imageUrl)
                        print("recipe=\(recipe)")
                        self.recipes.append(recipe)
                    }
                }
            }
            // call once
            self.recipeIndexInit()
        }
    }
    
    // Function: fetchRecipeImage()
    // Fetch the recipe image from Spoonacular website
    // by using the URLRequest and URLSession API
    func fetchRecipeImage(for rcp: Recipe, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let imgUrl: String?
        print("Total recipes count: \(self.recipes.count), current recipesIndex = \(self.recipesIndex)")
        
        if (self.recipes.count > 0) {
            // fetch next recipe item
            let imgUrlIdx = self.recipesIndex - 1
            imgUrl = self.recipes[imgUrlIdx].imageUrl
        } else {
            print("No recipe image!")
            self.sendAlertMessage()
            return
        }

        // fetch recipe image
        let url = URL(string: imgUrl!)!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
                if let taskError = error {
                    print("Task error: \(taskError)")
                    self.sendAlertMessage()
                } else {
                    let resp = response as! HTTPURLResponse
                    switch resp.statusCode {
                    case self.httpResponseOK:
                        let imgResult = self.prepareRecipeImage(data: data, error: error)
                        OperationQueue.main.addOperation {
                            completion(imgResult)
                        }
                    default:
                        print("Error HTTP Response Status Code \(resp.statusCode)")
                    }
                }
        }
        task.resume()
    }
    
    // Function: updateRecipeImageView()
    // Update the recipe image to the UI
    func updateRecipeImageView(for recipe: Recipe) {
        fetchRecipeImage(for: recipe) {
            (imgResult) in
            switch imgResult {
            case let .success(image):
                self.recipeImageView?.image = image
                print("Recipe image updated")
            case let .failure(error):
                print("Update recipe image with error: \(error)")
                self.sendAlertMessage()
            }
        }
    }

    // Function: prepareRecipeImage()
    // Check the recipe image fetch result
    func prepareRecipeImage(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard let image = UIImage(data: data!) else {
            self.sendAlertMessage()
            return .failure(error!)
            
        }
        return .success(image)
    }

    // Function: recipesIndexUpdate()
    // Update the index for navigating recipes
    func recipesIndexUpdate(direction :DirectionType) {
        print ("Current Recipe index = \(self.recipesIndex) of \(recipes.count)")
        
        // Cycle through recipes
        switch direction {
        case DirectionType.Next:
            if self.recipesIndex < recipes.count {
                self.recipesIndex += 1
            } else {
                if recipes.count > 0 {
                    self.recipesIndex = 1
                }
            }
        case DirectionType.Previous:
            if self.recipesIndex > 1 {
                self.recipesIndex -= 1
            } else {
                self.recipesIndex = recipes.count
            }
        }

        let arrayIdx = self.recipesIndex - 1
        
        if recipes.count > 0 {
            let nextRecipe = recipes[arrayIdx]
            self.updateRecipeImageView(for: nextRecipe)
            self.recipeTitle.text = recipes[arrayIdx].title
            print ("Current Recipe title = \(recipes[arrayIdx].title)")
            self.recipeType.text = "Recipe type: Vegan"
            self.recipeNumber.text = "Recipe \(self.recipesIndex) of \(recipes.count)"
        } else {
            // Unable to fetch Recipe data
            self.sendAlertMessage()
        }
    }
    
    // Function: sendAlertMessage()
    // called when failed to fetch recipe response from the Spoonacular REST API website
    func sendAlertMessage() {
        let alert = UIAlertController(title: "Alert", message: "Unable to fetch Recipe data, please try later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        print("UIAlertAction called.")
        }))
        
        DispatchQueue.main.async{
             self.recipeNumber.text = "Recipe not available!"
             self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Send request to the Spoonacular RESP API website
        fetchRecipeData {
            (dataResults) in
            switch dataResults {
            case let .success(recipes):
                print("Show first recipe")
                if let firstRecipeImage = recipes.first {
                    self.updateRecipeImageView(for: firstRecipeImage)
                    self.recipeTitle.text = recipes.first?.title
                    self.recipeType.text = "Recipe type: Vegan"
                    if recipes.count > 0 {
                        self.recipesIndex = 1
                    }
                    self.recipeNumber.text = "Recipe \(self.recipesIndex) of \(recipes.count)"
                }
                
                // Unable to fetch Recipe data
                if recipes.count < 1 {
                    self.sendAlertMessage()
                }
                
            case let .failure(error):
                print("Error fetching Recipe Data: \(error)")
                self.sendAlertMessage()
            }
        }
    }
}
