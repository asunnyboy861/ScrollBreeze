import FamilyControls
import ManagedSettings
import ManagedSettingsUI
import SwiftUI

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .regular,
            backgroundColor: UIColor(red: 0.05, green: 0.07, blue: 0.15, alpha: 1),
            icon: UIImage(named: "ScrollowBreathRing"),
            title: ShieldConfiguration.Label(text: "One scroll, three breaths.", color: .white),
            subtitle: ShieldConfiguration.Label(
                text: "Tap Scrollow to breathe — 8 seconds.",
                color: UIColor.white.withAlphaComponent(0.7)),
            primaryButtonLabel: .init(text: "Open Scrollow", color: .white),
            secondaryButtonLabel: .init(text: "Actually… no thanks", color: .systemTeal))
    }
}
