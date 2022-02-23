//
//  Router.swift
//  8 Ball
//
//  Created by Roman Topchii on 20.02.2022.
//

import Foundation
import UIKit

protocol RoutingDestinationBase {}

protocol Router {
   associatedtype RoutingDestination: RoutingDestinationBase
   func route(to destination: RoutingDestination)
}

