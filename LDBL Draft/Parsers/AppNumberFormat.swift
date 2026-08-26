import Foundation

struct AppNumberFormat {

    // MARK: - Decimal

    static func decimal(
        _ value: Double,
        places: Int = 1
    ) -> String {

        String(
            format: "%.\(places)f",
            locale: Locale(identifier: "en_US_POSIX"),
            value
        )
    }


    // MARK: - Grouped Decimal

    static func groupedDecimal(
        _ value: Double,
        places: Int = 1
    ) -> String {

        let formatter = NumberFormatter()

        formatter.locale =
            Locale(identifier: "en_US")

        formatter.numberStyle =
            .decimal

        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."

        formatter.minimumFractionDigits =
            places

        formatter.maximumFractionDigits =
            places

        return formatter.string(
            from: NSNumber(value: value)
        ) ?? decimal(
            value,
            places: places
        )
    }


    // MARK: - Percent

    static func percent(
        _ value: Double,
        places: Int = 1
    ) -> String {

        let percentage =
            value * 100

        return "\(decimal(percentage, places: places))%"
    }


    // MARK: - Whole Number

    static func wholeNumber(
        _ value: Double
    ) -> String {

        let formatter = NumberFormatter()

        formatter.locale =
            Locale(identifier: "en_US")

        formatter.numberStyle =
            .decimal

        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","

        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0

        return formatter.string(
            from: NSNumber(value: value)
        ) ?? "\(Int(value))"
    }


    // MARK: - Currency

    static func currency(
        _ value: Double
    ) -> String {

        let number =
            wholeNumber(value)

        return "$\(number)"
    }
}
