//
//  StructureFile.swift
//  Easy Cook
//
//  Created by Kua Jun Hong on 02/12/2020.
//

import Foundation

struct RecipeDetail {
    var id = 0
    var name = ""
    var likes = 0
    var view = 0
    var image = ""
    var category = ""
    var ingredients: [String] = []
    var steps: [String] = []
}

struct RecipeStep {
    var id = 0
    var desc = ""
}
