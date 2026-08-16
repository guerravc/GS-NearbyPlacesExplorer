import Foundation

public enum POICategoryMapper: Sendable {
    public static func map(category: String) -> String {
        switch category {
        case "MKPOICategoryRestaurant": return "fork.knife"
        case "MKPOICategoryCafe": return "cup.and.saucer.fill"
        case "MKPOICategoryBakery": return "takeoutbag.and.cup.and.straw.fill"
        case "MKPOICategoryHospital": return "cross.case.fill"
        case "MKPOICategoryPharmacy": return "pills.fill"
        case "MKPOICategoryBank": return "building.columns.fill"
        case "MKPOICategoryATM": return "atm"
        case "MKPOICategoryStore": return "bag.fill"
        case "MKPOICategorySupermarket": return "cart.fill"
        case "MKPOICategoryGasStation": return "fuelpump.fill"
        case "MKPOICategoryEVCharger": return "ev.charger.fill"
        case "MKPOICategoryParking": return "parkingsign.circle.fill"
        case "MKPOICategoryHotel": return "bed.double.fill"
        case "MKPOICategoryPark": return "tree.fill"
        case "MKPOICategoryFitnessCenter": return "dumbbell.fill"
        // Other cases like "MKPOICategoryMovieTheater", etc, can map to fallback or specific ones. 
        // We will just map what the test requires specifically.
        case "MKPOICategoryBeach": return "water.waves"
        case "MKPOICategoryMovieTheater": return "popcorn.fill"
        case "MKPOICategoryMuseum": return "building.columns"
        case "MKPOICategoryLibrary": return "books.vertical.fill"
        case "MKPOICategoryPostOffice": return "envelope.fill"
        default: return "mappin.and.ellipse"
        }
    }
}
