import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
  id: root

  property bool panelVisible: false
  property var allEntries: []
  property var readyThumbs: ({})
  property string filterText: ""

  readonly property string bg: "#1E1E1E"
  readonly property string fg: "#EBEBEB"
  readonly property string thumbDir: Quickshell.env("HOME") + "/.cache/quickshell/cliphist"

  function lineId(line) {
    return line.split("\t")[0];
  }

  function linePreview(line) {
    const i = line.indexOf("\t");
    return i >= 0 ? line.slice(i + 1) : line;
  }

  function lineIsImage(line) {
    return linePreview(line).indexOf("[[ binary data") === 0;
  }

  function rebuildModel() {
    entriesModel.clear();
    const f = filterText.toLowerCase();
    for (const line of allEntries) {
      const preview = linePreview(line);
      if (f.length === 0 || preview.toLowerCase().includes(f)) {
        const id = lineId(line);
        entriesModel.append({
          line: line,
          cid: id,
          preview: preview,
          isImage: lineIsImage(line),
          thumbReady: root.readyThumbs[id] === true
        });
      }
    }
    list.currentIndex = entriesModel.count > 0 ? 0 : -1;
  }

  function markThumbReady(id) {
    readyThumbs[id] = true;
    for (let i = 0; i < entriesModel.count; i++) {
      if (entriesModel.get(i).cid === id)
        entriesModel.setProperty(i, "thumbReady", true);
    }
  }

  function copyEntry(line) {
    copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist decode | wl-copy", "sh", line];
    copyProc.running = true;
    root.panelVisible = false;
  }

  function deleteEntry(line) {
    deleteProc.command = ["sh", "-c", "printf '%s' \"$1\" | cliphist delete", "sh", line];
    deleteProc.running = true;
  }

  onPanelVisibleChanged: {
    if (panelVisible) {
      allEntries = [];
      readyThumbs = {};
      filterInput.text = "";
      filterText = "";
      rebuildModel();
      listProc.running = true;
    } else {
      thumbProc.running = false;
      pruneProc.running = true;
    }
  }

  IpcHandler {
    target: "clipboard"

    function toggle(): void {
      root.panelVisible = !root.panelVisible;
    }
  }

  ListModel { id: entriesModel }

  Process {
    id: listProc
    command: ["cliphist", "list"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.allEntries = this.text.split("\n").filter(l => l.length > 0);
        root.rebuildModel();
        thumbProc.running = true;
      }
    }
  }

  // Decodes image entries into the thumbnail cache, emitting each id on
  // stdout as its thumbnail becomes available.
  Process {
    id: thumbProc
    command: ["sh", "-c", `
      mkdir -p "$1"
      cliphist list | grep -F '[[ binary data' | while IFS= read -r line; do
        id="$(printf '%s' "$line" | cut -f1)"
        out="$1/$id.png"
        if [ ! -s "$out" ]; then
          tmp="$out.tmp"
          printf '%s' "$line" | cliphist decode > "$tmp" && mv "$tmp" "$out" || rm -f "$tmp"
        fi
        echo "$id"
      done
    `, "sh", root.thumbDir]
    stdout: SplitParser {
      onRead: id => root.markThumbReady(id.trim())
    }
  }

  Process { id: copyProc }

  Process {
    id: deleteProc
    onExited: listProc.running = true
  }

  Process {
    id: pruneProc
    command: ["sh", "-c", `
      mkdir -p "$1"
      live_ids="$(cliphist list | cut -f1 | sort -u)"
      find "$1" -type f -name '*.tmp' -delete
      find "$1" -type f -name '*.png' -print0 | while IFS= read -r -d '' file; do
        id="$(basename "$file" .png)"
        printf '%s\n' "$live_ids" | grep -Fxq "$id" || rm -f "$file"
      done
    `, "sh", root.thumbDir]
  }

  PanelWindow {
    id: panel
    visible: root.panelVisible
    implicitWidth: 640
    implicitHeight: 460
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clipboard-panel"
    WlrLayershell.keyboardFocus: root.panelVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle {
      anchors.fill: parent
      color: root.bg
      border.color: "#4DB5BD"
      border.width: 1
      radius: 6

      Text {
        anchors.centerIn: parent
        visible: entriesModel.count === 0
        text: "clipboard history is empty"
        color: "#666666"
      }

      Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Rectangle {
          width: parent.width
          height: 30
          color: "#2A2A2A"
          radius: 4

          TextInput {
            id: filterInput
            anchors.fill: parent
            anchors.margins: 6
            color: root.fg
            font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter
            focus: true
            onTextChanged: {
              root.filterText = text;
              root.rebuildModel();
            }
            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                root.panelVisible = false;
                event.accepted = true;
              } else if (event.key === Qt.Key_Down) {
                list.incrementCurrentIndex();
                event.accepted = true;
              } else if (event.key === Qt.Key_Up) {
                list.decrementCurrentIndex();
                event.accepted = true;
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (list.currentIndex >= 0)
                  root.copyEntry(entriesModel.get(list.currentIndex).line);
                event.accepted = true;
              } else if (event.key === Qt.Key_Delete) {
                if (list.currentIndex >= 0)
                  root.deleteEntry(entriesModel.get(list.currentIndex).line);
                event.accepted = true;
              }
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              visible: filterInput.text.length === 0
              text: "type to filter…"
              color: "#666666"
              font.pixelSize: 14
            }
          }
        }

        ListView {
          id: list
          width: parent.width
          height: parent.height - 38
          clip: true
          model: entriesModel
          currentIndex: 0

          delegate: Rectangle {
            required property int index
            required property string line
            required property string cid
            required property string preview
            required property bool isImage
            required property bool thumbReady

            width: list.width
            height: isImage ? 76 : 28
            radius: 4
            color: ListView.isCurrentItem ? "#333333" : "transparent"

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              anchors.right: parent.right
              anchors.rightMargin: 8
              visible: !isImage
              text: preview
              color: root.fg
              font.pixelSize: 13
              elide: Text.ElideRight
            }

            Image {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              height: 64
              width: 320
              visible: isImage && thumbReady
              source: thumbReady ? "file://" + root.thumbDir + "/" + cid + ".png" : ""
              fillMode: Image.PreserveAspectFit
              horizontalAlignment: Image.AlignLeft
              asynchronous: true
              cache: false
            }

            Text {
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              visible: isImage && !thumbReady
              text: preview
              color: "#999999"
              font.pixelSize: 13
            }

            MouseArea {
              anchors.fill: parent
              onClicked: root.copyEntry(line)
            }
          }
        }
      }
    }
  }
}
