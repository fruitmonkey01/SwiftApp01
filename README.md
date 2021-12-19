Project: Web Services for iOS App by using Spoonacular REST API

IMPORTANT: 
FILE: ViewController.swift
Line 60: Replace and use the API Key registered at https://www.spoonacular.com 

<br />
![alt ScreenImage](https://github.com/fruitmonkey01/SwiftApp01.git/blob/main/SwiftAppUI.png)
<br />

Procedures:

1. Program start by calling following functions
Function: fetchRecipeData()
Send recipe request with Spoonacular REST API website
1.1. Register your API Key at Spponacular website: https://www.spoonacular.com
1.2. Url query string: 'apiKey' Use your registered API Key (32 Letters) in the string: apiKey="xxx"
1.3. Url query string: 'query' The Type (String) of recipe
1.4. Url query string: 'offset' The number of results to skip (between 0 and 900), default is '0'
1.5. Url query string: 'number' The number of expected results (between 1 and 100), default is '10'

2. Call the function: parseRecipeJson() 
to parse the recipe response from Spoonacular REST API website
by using JSONSerialization API call to unwrap JSON Object

3. Call the function: fetchRecipeImage() 
to fetch the recipe image from Spoonacular website
by using the URLRequest and URLSession API

4. Call the function: updateRecipeImageView()
to pdate the recipe image to the UI

5. Click the "Next" and "Previous" UIButton to navigate Vegan recipes.

6. Popup alert dialog function: sendAlertMessage()
called only when failed to fetch recipe response from the Spoonacular REST API website

7. Recipe response data (JSON format)

{
 results:
 [{id, title, image, imageType}*],
 offset, number, totalResults
 }
 
 8. Example for the recipe response

Sample recipe JSON data (15 items)

RecipeJsonDataString=Optional(

"{
\"results\":[
    {\"id\":1095996,\"title\":\"Vegan Eggnog\",\"image\":\"https://spoonacular.com/recipeImages/1095996-312x231.jpg\",\"imageType\":\"jpg\"},
    {\"id\":664472,\"title\":\"Vegan Potato Salad\",\"image\":\"https://spoonacular.com/recipeImages/664472-312x231.jpg\",\"imageType\":\"jpg\"} ],
    
\"offset\":0,
\"number\":2,
\"totalResults\":693
}"

)


