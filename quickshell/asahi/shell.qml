import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
  anchors {
    bottom: true
    left: true
    right: true
  }
  readonly property string bg: "#1E1E1E"
  readonly property string fg: "#EBEBEB"
  property int activeWorkspace: 1
  property var availableWorkspaces: []

  color: bg
  implicitHeight: 15
  Text {
    anchors {
      left: parent.left
      leftMargin: 5
      verticalCenter: parent.verticalCenter
    }
    color: fg
    text: activeWorkspace
  }
  Row {
    anchors {
      right: parent.right
      rightMargin: 5
    }
    spacing: 5
    Text {
      id: barRightPart1
      color: "#4DB5BD"
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart2
      color: fg
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart3
      color: "#E1BEE9"
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart4
      color: "#FFF244"
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart5
      color: "#66EB66"
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart6
      color: fg
    }
    Text {
      color: fg
      text: "|"
    }
    Text {
      id: barRightPart7
      color: "#FFB74D"
    }
  }
  Process {
    id: status
    running: true
    command: [ "i3status" ]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.split("|")
        barRightPart1.text = (parts[0] || "").trim()  // WiFi
        barRightPart2.text = (parts[1] || "").trim()  // Disk
        barRightPart3.text = (parts[2] || "").trim()  // RAM
        barRightPart4.text = (parts[3] || "").trim()  // CPU
        barRightPart5.text = (parts[4] || "").trim()  // Temp
        barRightPart6.text = (parts[5] || "").trim()  // Time
        barRightPart7.text = (parts[6] || "").trim()  // Battery
      }
    }
  }
  Process {
    id: niriEvents
    command: ["niri", "msg", "--json", "event-stream"]
    running: true
    stdout: SplitParser {
      onRead: data => {
        let event = JSON.parse(data)
        // There is unique inherent id for each workspace and also a relative idx, so you need to get idx
        if (event.WorkspacesChanged) {
          availableWorkspaces = event.WorkspacesChanged.workspaces
          let focused = availableWorkspaces.find(w => w.is_active)
          activeWorkspace = focused.idx
        }
        if (event.WorkspaceActivated) {
          let ws = availableWorkspaces.find(w => w.id === event.WorkspaceActivated.id)
          if (ws) activeWorkspace = ws.idx
        }
      }
    }
  }
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: status.running = true
  }
}
