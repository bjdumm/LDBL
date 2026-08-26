import SwiftUI

struct ManagerAvatarView: View {

    let managerName: String
    let size: CGFloat

    var body: some View {

        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(
                width: size,
                height: size
            )
            .clipShape(Circle())
    }

    private var imageName: String {

        switch ManagerNameNormalizer.normalize(managerName) {

        case "Baran":
            return "manager_baran"

        case "Brandon":
            return "manager_brandon"

        case "Darah":
            return "manager_darah"

        case "Nate":
            return "manager_nate"

        case "Panda":
            return "manager_panda"

        case "Hancharik":
            return "manager_hancharik"

        case "Penksa":
            return "manager_penksa"

        case "Sub":
            return "manager_sub"

        case "Todd":
            return "manager_todd"

        case "Tony":
            return "manager_tony"

        case "Yuhas":
            return "manager_yuhas"

        default:
            return "manager_placeholder"
        }
    }
}
