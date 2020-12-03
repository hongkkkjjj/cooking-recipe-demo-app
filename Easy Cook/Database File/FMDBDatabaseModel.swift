//
//  FMDBDatabaseModel.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 1/12/2020.
//

import UIKit
import FMDB

class FMDBDatabaseModel: NSObject {
    
    private static var databasePath = ""
    
    internal static func startup() {
        guard let docsDirectoryUrl: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                return
        }
        
        databasePath = docsDirectoryUrl.appendingPathComponent("easycook.db").path
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                var success = db.executeStatements("PRAGMA foreign_keys = ON")
                print("Foreign Key turn on: \(success)")
                
                // drop table
                
//                success = db.executeStatements("DROP TABLE IF EXISTS recipe_ingredient")
//                success = db.executeStatements("DROP TABLE IF EXISTS favor_recipe")
//                success = db.executeStatements("DROP TABLE IF EXISTS recipe_step")
//                success = db.executeStatements("DROP TABLE IF EXISTS recipe_list")
//                print("drop table success \(success)")
                
                success = db.executeStatements("""
                    CREATE TABLE IF NOT EXISTS "recipe_list" (
                    "rid"    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                    "name"    TEXT NOT NULL,
                    "likes"    INTEGER NOT NULL,
                    "view"    INTEGER NOT NULL,
                    "image"    TEXT NOT NULL,
                    "category" TEXT NOT NULL
                    );
                """)
                print("Create table Recipe List success: \(success)")
                
                success = db.executeStatements("""
                    CREATE TABLE IF NOT EXISTS "recipe_ingredient" (
                        "fid"    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        "rid"    INTEGER NOT NULL,
                        "ingredient"    TEXT NOT NULL,
                        FOREIGN KEY(rid) REFERENCES recipe_list(rid)
                    );
                """)
                print("Create table Recipe Ingredient success: \(success)")
                
                success = db.executeStatements("""
                    CREATE TABLE IF NOT EXISTS "favor_recipe" (
                        "fid"    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        "rid"    INTEGER NOT NULL,
                        FOREIGN KEY(rid) REFERENCES recipe_list(rid)
                    );
                    """
                )
                print("Create table Favor Recipe success: \(success)")
                
                success = db.executeStatements("""
                    CREATE TABLE IF NOT EXISTS "recipe_step" (
                        "sid"    INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                        "rid"    INTEGER NOT NULL,
                        "step"    INTEGER NOT NULL,
                        "desc"    TEXT NOT NULL,
                        FOREIGN KEY(rid) REFERENCES recipe_list(rid)
                    );
                """)
                print("Create table Recipe Step success: \(success)")
            }
        }
    }
    
    internal static func checkRowCount() -> Bool {
        var count = 0
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                if let rs = db.executeQuery("SELECT rid FROM recipe_list LIMIT 5", withArgumentsIn: []) {
                    while (rs.next()) {
                        count += 1
                    }
                }
            }
        }
        return count > 0
    }
    
    internal static func insertData(recipeList: [RecipeDetail]) -> Bool {
        var success: Bool = false
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                var index = 0
                for recipe in recipeList {
                    index += 1
                    success = db.executeUpdate("INSERT INTO recipe_list (name, image, category, likes, view) VALUES (?, ?, ?, ?, ?)", withArgumentsIn: [recipe.name, recipe.image, recipe.category, recipe.likes, recipe.view])
                    
                    for ingredient in recipe.ingredients {
                        success = db.executeUpdate("INSERT INTO recipe_ingredient (rid, ingredient) VALUES (?, ?)", withArgumentsIn: [index, ingredient])
                    }
                    
                    var stepNum = 0
                    for step in recipe.steps {
                        stepNum += 1
                        success = db.executeUpdate("INSERT INTO recipe_step (rid, step, desc) VALUES (?, ?, ?)", withArgumentsIn: [index, stepNum, step])
                    }
                }
            }
        }
        return success
    }
    
    internal static func retrievePopularAndFavouriteRecipe() -> [RecipeDetail] {
        var recipeArr: [RecipeDetail] = []
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                if let rs = db.executeQuery("SELECT * FROM recipe_list ORDER BY view DESC LIMIT 5", withArgumentsIn: []) {
                    var index = 0
                    while rs.next() {
                        index += 1
                        var recipe = RecipeDetail()
                        recipe.id = Int(rs.int(forColumn: "rid"))
                        recipe.name = rs.string(forColumn: "name") ?? ""
                        recipe.image = rs.string(forColumn: "image") ?? ""
                        recipe.category = rs.string(forColumn: "category") ?? ""
                        recipe.view = Int(rs.int(forColumn: "view"))
                        recipe.likes = Int(rs.int(forColumn: "likes"))
                        
                        if let ingredientRs = db.executeQuery("SELECT ingredient FROM recipe_ingredient WHERE rid = ?", withArgumentsIn: [index]) {
                            while ingredientRs.next() {
                                let ingredient = ingredientRs.string(forColumn: "ingredient") ?? ""
                                recipe.ingredients.append(ingredient)
                            }
                        }
                        
                        var stepList: [RecipeStep] = []
                        if let stepRs = db.executeQuery("SELECT step, desc FROM recipe_step WHERE rid = ? ORDER BY step", withArgumentsIn: [index]) {
                            while stepRs.next() {
                                let stepNum = Int(stepRs.int(forColumn: "step"))
                                let desc = stepRs.string(forColumn: "desc") ?? ""
                                let recipeStep = RecipeStep(id: stepNum, desc: desc)
                                stepList.append(recipeStep)
                            }
                        }
                        for step in stepList {
                            recipe.steps.append(step.desc)
                        }
                        recipeArr.append(recipe)
                    }
                }
                
                if let favorRs = db.executeQuery("SELECT * FROM recipe_list AS r INNER JOIN favor_recipe AS f ON r.rid = f.rid ORDER BY RANDOM() LIMIT 5", withArgumentsIn: []) {
                    while favorRs.next() {
                        var recipe = RecipeDetail()
                        let rid = Int(favorRs.int(forColumn: "rid"))
                        recipe.id = rid
                        recipe.name = favorRs.string(forColumn: "name") ?? ""
                        recipe.image = favorRs.string(forColumn: "image") ?? ""
                        recipe.category = favorRs.string(forColumn: "category") ?? ""
                        recipe.view = Int(favorRs.int(forColumn: "view"))
                        recipe.likes = Int(favorRs.int(forColumn: "likes"))
                        
                        if let ingredientRs = db.executeQuery("SELECT ingredient FROM recipe_ingredient WHERE rid = ?", withArgumentsIn: [rid]) {
                            while ingredientRs.next() {
                                let ingredient = ingredientRs.string(forColumn: "ingredient") ?? ""
                                recipe.ingredients.append(ingredient)
                            }
                        }
                        
                        var stepList: [RecipeStep] = []
                        if let stepRs = db.executeQuery("SELECT step, desc FROM recipe_step WHERE rid = ? ORDER BY step", withArgumentsIn: [rid]) {
                            while stepRs.next() {
                                let stepNum = Int(stepRs.int(forColumn: "step"))
                                let desc = stepRs.string(forColumn: "desc") ?? ""
                                let recipeStep = RecipeStep(id: stepNum, desc: desc)
                                stepList.append(recipeStep)
                            }
                        }
                        for step in stepList {
                            recipe.steps.append(step.desc)
                        }
                        recipeArr.append(recipe)
                    }
                }
            }
        }
        return recipeArr
    }
    
    internal static func retrieveFavouriteRecipeOnly() -> [RecipeDetail] {
        var recipeArr: [RecipeDetail] = []
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                if let rs = db.executeQuery("SELECT * FROM recipe_list AS r INNER JOIN favor_recipe AS f ON r.rid = f.rid ORDER BY RANDOM()", withArgumentsIn: []) {
                    while rs.next() {
                        var recipe = RecipeDetail()
                        let rid = Int(rs.int(forColumn: "rid"))
                        recipe.id = rid
                        recipe.name = rs.string(forColumn: "name") ?? ""
                        recipe.image = rs.string(forColumn: "image") ?? ""
                        recipe.category = rs.string(forColumn: "category") ?? ""
                        recipe.view = Int(rs.int(forColumn: "view"))
                        recipe.likes = Int(rs.int(forColumn: "likes"))
                        
                        if let ingredientRs = db.executeQuery("SELECT ingredient FROM recipe_ingredient WHERE rid = ?", withArgumentsIn: [rid]) {
                            while ingredientRs.next() {
                                let ingredient = ingredientRs.string(forColumn: "ingredient") ?? ""
                                recipe.ingredients.append(ingredient)
                            }
                        }
                        
                        var stepList: [RecipeStep] = []
                        if let stepRs = db.executeQuery("SELECT step, desc FROM recipe_step WHERE rid = ? ORDER BY step", withArgumentsIn: [rid]) {
                            while stepRs.next() {
                                let stepNum = Int(stepRs.int(forColumn: "step"))
                                let desc = stepRs.string(forColumn: "desc") ?? ""
                                let recipeStep = RecipeStep(id: stepNum, desc: desc)
                                stepList.append(recipeStep)
                            }
                        }
                        for step in stepList {
                            recipe.steps.append(step.desc)
                        }
                        recipeArr.append(recipe)
                    }
                }
            }
        }
        
        return recipeArr
    }
    
    internal static func updateRecipe(id: Int, type: ValueType, value: Int, addFavor: Bool = false) -> Bool {
        var success = false
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                switch type {
                case .likes:
                    success = db.executeUpdate("UPDATE recipe_list SET likes = ? WHERE rid = ?", withArgumentsIn: [value, id])
                    
                    if addFavor {
                        // add row into favor_recipe
                        success = db.executeUpdate("INSERT INTO favor_recipe (rid) VALUES (?)", withArgumentsIn: [id])
                        print("Added favor")
                    } else {
                        // remove row from favor_recipe
                        success = db.executeUpdate("DELETE FROM favor_recipe WHERE rid = ?", withArgumentsIn: [id])
                        print("Removed favor")
                    }
                    
                case .view:
                    success = db.executeUpdate("UPDATE recipe_list SET view = ? WHERE rid = ?", withArgumentsIn: [value, id])
                }
            }
        }
        
        return success
    }
    
    internal static func checkIsFavorRecipe(rid: Int) -> Bool {
        var count = 0
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                if let rs = db.executeQuery("SELECT rid FROM favor_recipe WHERE rid = ?", withArgumentsIn: [rid]) {
                    while rs.next() {
                        count += 1
                    }
                }
            }
        }
        
        return count > 0
    }
    
    internal static func removeRecipe(rid: Int) -> Bool {
        var success = false
        
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                success = db.executeUpdate("DELETE FROM favor_recipe WHERE rid = ?", withArgumentsIn: [rid])
                success = db.executeUpdate("DELETE FROM favor_recipe WHERE rid = ?", withArgumentsIn: [rid])
                success = db.executeUpdate("DELETE FROM recipe_ingredient WHERE rid = ?", withArgumentsIn: [rid])
                success = db.executeUpdate("DELETE FROM recipe_list WHERE rid = ?", withArgumentsIn: [rid])
            }
        }
        
        print("Removed selected recipe from all table success \(success)")
        return success
    }
    
    internal static func getMaximumRecipe() -> [RecipeDetail] {
        var recipeArr: [RecipeDetail] = []
        if let dbQueue = FMDatabaseQueue(path: databasePath) {
            dbQueue.inDatabase { (db: FMDatabase) in
                if let rs = db.executeQuery("SELECT * FROM recipe_list ORDER BY RANDOM()", withArgumentsIn: []) {
                    var index = 0
                    while rs.next() {
                        index += 1
                        var recipe = RecipeDetail()
                        recipe.id = Int(rs.int(forColumn: "rid"))
                        recipe.name = rs.string(forColumn: "name") ?? ""
                        recipe.image = rs.string(forColumn: "image") ?? ""
                        recipe.category = rs.string(forColumn: "category") ?? ""
                        recipe.view = Int(rs.int(forColumn: "view"))
                        recipe.likes = Int(rs.int(forColumn: "likes"))
                        
                        if let ingredientRs = db.executeQuery("SELECT ingredient FROM recipe_ingredient WHERE rid = ?", withArgumentsIn: [index]) {
                            while ingredientRs.next() {
                                let ingredient = ingredientRs.string(forColumn: "ingredient") ?? ""
                                recipe.ingredients.append(ingredient)
                            }
                        }
                        
                        var stepList: [RecipeStep] = []
                        if let stepRs = db.executeQuery("SELECT step, desc FROM recipe_step WHERE rid = ? ORDER BY step", withArgumentsIn: [index]) {
                            while stepRs.next() {
                                let stepNum = Int(stepRs.int(forColumn: "step"))
                                let desc = stepRs.string(forColumn: "desc") ?? ""
                                let recipeStep = RecipeStep(id: stepNum, desc: desc)
                                stepList.append(recipeStep)
                            }
                        }
                        for step in stepList {
                            recipe.steps.append(step.desc)
                        }
                        recipeArr.append(recipe)
                    }
                }
            }
        }
        return recipeArr
    }
    
    enum ValueType {
        case view, likes
    }
}
