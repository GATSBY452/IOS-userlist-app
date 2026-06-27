//
//  ManagedUserClass.swift
//  Userlists
//
//  Created by Yusuf Abbas on 26/06/2026.
//

import CoreData

/// Maps to the `ManagedUser` entity in UsersApp.xcdatamodeld.
///
/// Codegen is set to "Manual/None" in the model editor — this file and
/// `ManagedUser+CoreDataProperties.swift` are written by hand below instead
/// of Xcode-generated, so they're visible and explainable in this codebase
/// rather than living in DerivedData.
@objc(ManagedUser)
public final class ManagedUser: NSManagedObject {}
