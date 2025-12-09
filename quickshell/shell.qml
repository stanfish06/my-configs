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

  color: bg
  implicitHeight: 15

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
      color: fg
    }
  }
  Process {
    id: status
    running: true
    command: [ "i3status", "--run-once" ]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = text.split("|")
        barRightPart1.text = (parts[1] || "").trim()
        barRightPart2.text = ("Disk:" + parts[4] || "").trim()
        barRightPart3.text = ("CPU:" + parts[5] + "%" || "").trim()
        barRightPart4.text = ("RAM:" + parts[6] + "/" + parts[7] || "").trim()
        barRightPart5.text = (parts[8] || "").trim()
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
