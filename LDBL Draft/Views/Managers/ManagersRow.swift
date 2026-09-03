import SwiftUI

struct ManagerRow: View {

    let manager: ManagerProfile

    var body: some View {

        HStack(spacing: 14) {

            ManagerAvatarView(
                managerName: manager.name,
                size: 48
            )


            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(manager.name)
                    .font(.headline)


                if manager.actualCareerWins +
                    manager.actualCareerLosses > 0 {

                    Text(
                        "\(manager.actualCareerWins)-\(manager.actualCareerLosses) actual fantasy"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }


                if manager.beerGameSeasonsPlayed > 0 {

                    Text(
                        verbatim:
                            "\(AppNumberFormat.decimal(manager.averageBeerGamePoints)) avg Beer Game pts"
                    )
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                }
            }


            Spacer()


         /*   if manager.totalWinnings > 0 {

               Text(
                    verbatim:
                        AppNumberFormat.currency(
                            manager.totalWinnings
                        )
                )
                .font(.subheadline)
                .fontWeight(
                    .semibold
                )
            }*/
        }
        .padding(
            .vertical,
            4
        )
    }
}
