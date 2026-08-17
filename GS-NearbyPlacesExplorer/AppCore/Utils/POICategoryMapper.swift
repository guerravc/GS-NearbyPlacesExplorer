import Foundation

public enum POICategoryMapper: Sendable {
    public static func map(category: String) -> String {
        switch category {
        case "restaurant", "fast_food", "food_court":
            return "fork.knife"
        case "cafe", "bar", "pub":
            return "cup.and.saucer.fill"
        case "bakery", "ice_cream":
            return "takeoutbag.and.cup.and.straw.fill"
        case "hospital", "clinic", "doctors", "dentist", "veterinary":
            return "cross.case.fill"
        case "pharmacy":
            return "pills.fill"
        case "bank":
            return "building.columns.fill"
        case "atm":
            return "atm"
        case "convenience", "marketplace":
            return "bag.fill"
        case "supermarket":
            return "cart.fill"
        case "fuel":
            return "fuelpump.fill"
        case "charging_station":
            return "ev.charger.fill"
        case "parking", "parking_entrance":
            return "parkingsign.circle.fill"
        case "hotel", "hostel":
            return "bed.double.fill"
        case "gym":
            return "dumbbell.fill"
        case "cinema":
            return "popcorn.fill"
        case "place_of_worship", "school", "university":
            return "building.columns"
        case "library":
            return "books.vertical.fill"
        case "post_office":
            return "envelope.fill"
        default: return "mappin.and.ellipse"
        }
    }
}
