//
//  LiveMatch.swift
//  App
//
//  Created by Dalton Claybrook on 6/5/18.
//

import FluentMySQL

final class LiveMatch: MySQLModel {
    var id: Int?
    let owlId: Int
    let team1Score: Int
    let team2Score: Int
}

