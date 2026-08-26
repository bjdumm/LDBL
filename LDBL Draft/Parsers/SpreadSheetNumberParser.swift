import Foundation

struct SpreadsheetNumberParser {

    static func number(
        _ text: String
    ) -> Double? {

        var value =
            text
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .replacingOccurrences(
                    of: "$",
                    with: ""
                )
                .replacingOccurrences(
                    of: "%",
                    with: ""
                )
                .replacingOccurrences(
                    of: " ",
                    with: ""
                )


        guard !value.isEmpty,
              value != "-"
        else {
            return nil
        }


        var isNegative = false

        if value.hasPrefix("(") &&
            value.hasSuffix(")") {

            isNegative = true

            value.removeFirst()
            value.removeLast()
        }


        let lastDot =
            value.lastIndex(of: ".")

        let lastComma =
            value.lastIndex(of: ",")


        // MARK: - Both separators

        if let dot = lastDot,
           let comma = lastComma {

            /*
             Whichever separator appears LAST
             is assumed to be the decimal
             separator.

             Examples:

             1,345.50
             1.345,50
            */

            if dot > comma {

                value =
                    value.replacingOccurrences(
                        of: ",",
                        with: ""
                    )

            } else {

                value =
                    value.replacingOccurrences(
                        of: ".",
                        with: ""
                    )

                value =
                    value.replacingOccurrences(
                        of: ",",
                        with: "."
                    )
            }
        }


        // MARK: - Only comma

        else if let comma = lastComma {

            let digitsAfter =
                value.distance(
                    from:
                        value.index(
                            after: comma
                        ),
                    to: value.endIndex
                )

            let before =
                String(
                    value[..<comma]
                )


            /*
             1,434 = thousands separator
             77,6  = decimal separator
             0,500 = decimal separator
            */

            if digitsAfter == 3 &&
                before != "0" {

                value =
                    value.replacingOccurrences(
                        of: ",",
                        with: ""
                    )

            } else {

                value =
                    value.replacingOccurrences(
                        of: ",",
                        with: "."
                    )
            }
        }


        // MARK: - Only period

        else if let dot = lastDot {

            let digitsAfter =
                value.distance(
                    from:
                        value.index(
                            after: dot
                        ),
                    to: value.endIndex
                )

            let before =
                String(
                    value[..<dot]
                )


            /*
             1.434 = thousands separator
             77.6  = decimal separator
             0.500 = decimal separator
            */

            if digitsAfter == 3 &&
                before != "0" {

                value =
                    value.replacingOccurrences(
                        of: ".",
                        with: ""
                    )
            }
        }


        guard let number =
                Double(value)
        else {
            return nil
        }


        return isNegative
            ? -number
            : number
    }


    static func percentage(
        _ text: String
    ) -> Double {

        guard let number =
                number(text)
        else {
            return 0
        }

        if text.contains("%") ||
            number > 1 {

            return number / 100
        }

        return number
    }
}
