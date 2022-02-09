//
//  main.swift
//  TestApp
//
//  Created by Apple on 09/02/22.
//

import Foundation


let jsonString = """
{
"name": "Jitendra",

}
"""

let data = jsonString.data(using: .utf8)!


let json = try! JSONDecoder().decode(JSON.self, from: data)
let jsonData = try? JSONSerialization.data(withJSONObject: json.dictionary!, options: [])
print(jsonData)



