//@ pragma UseQApplication

import QtQml
import Quickshell
import "NiceRice"
import "NiceRice/Notifications"
import "NiceRice/CalendarApp"
import "NiceRice/SidePanelApp"

ShellRoot {

    LazyWindow {
        ipcTarget: "khal_config_window"
        onActivation: active => {
            if (active)
                KhalConfig.reload();
        }

        KhalConfigWindow {}
    }

    LazyWindow {
        ipcTarget: "sidepanel_window"

        SidePanelWindow {}
    }

    EventAddWindow {}

    NotificationsPanel {}

    StatusbarWindow {}
}
