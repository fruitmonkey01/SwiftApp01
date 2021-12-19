//
//  Recipe.swift
//  Swift_1210
//
//

import Foundation

struct Recipe {
    var title: String
    var imageUrl: String

    init(title: String, imageUrl: String) {
        self.title = title
        self.imageUrl = imageUrl
    }

    init() {
        self.init(title: "", imageUrl: "")
    }
}
