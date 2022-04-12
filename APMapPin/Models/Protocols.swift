//
//  Protocols.swift
//  APMapPin
//
//  Created by Gary Hamann on 4/12/22.
//

import Foundation

// Called when data is received from the autopilot
protocol ReceiveApMessageDelegate{
    func messageIn(message:String)
}

// watch messages
protocol MapMessageDelegate{
    func mapMessage(msg:String)
}

protocol NavUpdateReadyDelegate{
    func navUpdateReady()
}
