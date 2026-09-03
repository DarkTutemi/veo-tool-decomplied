pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "referencePackPanel"
    color: "transparent"
    border.width: 0
    Accessible.name: "Nguồn tham khảo và Reference Pack"
    Accessible.role: Accessible.Pane

    property var controlPlaneBridge: null
    property string selectedPackId: ""
    property string feedbackMessage: ""
    property bool editorOpen: false
    property bool editingExisting: false
    property int modelRevision: 0

    readonly property var packModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.referencePackModel : null
    readonly property bool actionBusy: Boolean(root.controlPlaneBridge
        && root.controlPlaneBridge.actionBusy)
    readonly property var selectedPack: {
        const revision = root.modelRevision
        return root.packForId(root.selectedPackId)
    }
    readonly property bool hasPack: String(
        root.selectedPack.referencePackId || "").length > 0

    ListModel { id: selectedSourceModel }

    function packForId(packId) {
        if (!root.packModel)
            return ({})
        const wanted = String(packId || "")
        for (let index = 0; index < Number(root.packModel.count || 0); ++index) {
            const row = root.packModel.get(index) || ({})
            if (String(row.referencePackId || "") === wanted)
                return row
        }
        return ({})
    }

    function reconcileSelection() {
        if (root.hasPack) {
            root.rebuildSources()
            return
        }
        root.selectedPackId = root.packModel
                && Number(root.packModel.count || 0) > 0
            ? String((root.packModel.get(0) || ({})).referencePackId || "")
            : ""
        root.rebuildSources()
    }

    function rebuildSources() {
        selectedSourceModel.clear()
        const rows = root.selectedPack.sources || []
        for (let index = 0; index < rows.length; ++index)
            selectedSourceModel.append(rows[index])
    }

    function selectPack(packId) {
        const cleanId = String(packId || "")
        if (!cleanId || cleanId === root.selectedPackId)
            return
        root.selectedPackId = cleanId
        root.feedbackMessage = ""
        root.rebuildSources()
    }

    function openCreate() {
        root.editingExisting = false
        packTitleInput.text = ""
        packDescriptionInput.text = ""
        root.editorOpen = true
        Qt.callLater(function() { packTitleInput.forceActiveFocus() })
    }

    function openEdit() {
        if (!root.hasPack)
            return
        root.editingExisting = true
        packTitleInput.text = String(root.selectedPack.title || "")
        packDescriptionInput.text = String(root.selectedPack.description || "")
        root.editorOpen = true
        Qt.callLater(function() { packTitleInput.forceActiveFocus() })
    }

    function saveMetadata() {
        if (!root.controlPlaneBridge || !packTitleInput.text.trim())
            return
        root.controlPlaneBridge.callTool("tool1.reference_pack.save", {
            "reference_pack_id": root.editingExisting
                ? root.selectedPackId : "",
            "title": packTitleInput.text.trim(),
            "description": packDescriptionInput.text.trim()
        })
    }

    function appendSources(sources) {
        if (!root.controlPlaneBridge || !root.hasPack || !sources.length)
            return
        root.controlPlaneBridge.callTool("tool1.reference_pack.save", {
            "reference_pack_id": root.selectedPackId,
            "append_sources": true,
            "sources": sources
        })
    }

    onSelectedPackIdChanged: Qt.callLater(root.rebuildSources)
    Component.onCompleted: Qt.callLater(root.reconcileSelection)

    Connections {
        target: root.packModel
        function onModelReset() {
            root.modelRevision += 1
            Qt.callLater(root.reconcileSelection)
        }
        function onCountChanged() {
            root.modelRevision += 1
            Qt.callLater(root.reconcileSelection)
        }
    }

    Connections {
        target: root.controlPlaneBridge
        function onActionFinished(toolName, ok, data, message) {
            if (String(toolName || "") !== "tool1.reference_pack.save")
                return
            root.feedbackMessage = ok
                ? "Reference Pack đã có revision mới; kế hoạch cũ vẫn giữ nguồn đã đóng băng."
                : String(message || "Không thể lưu Reference Pack.")
            if (!ok)
                return
            const result = (data || {}).reference_pack_result || ({})
            const createdId = String(result.reference_pack_id || "")
            if (createdId)
                root.selectedPackId = createdId
            root.editorOpen = false
            sourceIntake.finishImport(true)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: Theme.space3

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 13
                color: Theme.accentSoft
                UiIcon {
                    anchors.centerIn: parent
                    name: "ui/layers"
                    tone: Theme.accent
                    iconSize: 22
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    Layout.fillWidth: true
                    text: "Nguồn tham khảo"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Tuyển chọn ý tưởng, kịch bản, link, audio, video và sản phẩm thành Reference Pack có revision/hash."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontBody
                    elide: Text.ElideRight
                }
            }
            AppButton {
                objectName: "referencePackCreateButton"
                text: "Pack mới"
                leadingIcon: "ui/plus"
                primary: true
                enabled: !root.actionBusy
                onClicked: root.openCreate()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.space3

            Panel {
                Layout.preferredWidth: 286
                Layout.minimumWidth: 250
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: "REFERENCE PACK"
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            font.weight: Font.Bold
                            font.letterSpacing: 0.6
                        }
                        Foundation.StatusPill {
                            text: String(root.packModel
                                ? root.packModel.count || 0 : 0)
                            tone: Theme.textMuted
                        }
                    }

                    ListView {
                        id: packList
                        objectName: "referencePackList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        reuseItems: true
                        spacing: 6
                        boundsBehavior: Flickable.StopAtBounds
                        model: root.packModel
                        ScrollBar.vertical: ScrollBar {}

                        delegate: Button {
                            id: packRow
                            required property var modelData
                            width: ListView.view ? ListView.view.width : 266
                            height: 78
                            text: String(packRow.modelData.title || "Reference Pack")
                            hoverEnabled: true
                            activeFocusOnTab: true
                            Accessible.name: text
                            Accessible.description: String(
                                packRow.modelData.sourceCount || 0)
                                + " nguồn, revision "
                                + String(packRow.modelData.version || 0)
                            onClicked: root.selectPack(
                                String(packRow.modelData.referencePackId || ""))

                            contentItem: ColumnLayout {
                                spacing: 3
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(packRow.modelData.title
                                            || "Reference Pack")
                                        color: Theme.text
                                        font.pixelSize: Theme.fontBody
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    Foundation.StatusPill {
                                        text: "V" + String(
                                            packRow.modelData.version || 0)
                                        tone: Theme.accent
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(packRow.modelData.readyCount || 0)
                                        + " sẵn sàng · "
                                        + String(packRow.modelData.invalidCount || 0)
                                        + " cần sửa"
                                    color: Theme.textMuted
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: String(packRow.modelData.description
                                        || "Chưa có mô tả")
                                    color: Theme.textFaint
                                    font.pixelSize: Theme.fontMetadata
                                    elide: Text.ElideRight
                                }
                            }
                            background: Rectangle {
                                radius: Theme.radiusSmall
                                color: String(packRow.modelData.referencePackId || "")
                                        === root.selectedPackId
                                    ? Theme.accentSoft
                                    : packRow.hovered ? Theme.hover : Theme.elevated
                                border.width: 1
                                border.color: String(
                                    packRow.modelData.referencePackId || "")
                                        === root.selectedPackId
                                    ? Theme.accent : Theme.borderSoft
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !root.packModel
                                || Number(root.packModel.count || 0) === 0
                            width: Math.min(parent.width - 24, 220)
                            text: "Chưa có pack. Tạo một pack rồi nạp nguồn thực tế."
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBody
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                        }
                    }

                    AppButton {
                        objectName: "referencePackEditButton"
                        Layout.fillWidth: true
                        text: "Sửa tên & mô tả"
                        leadingIcon: "ui/pencil"
                        enabled: root.hasPack && !root.actionBusy
                        onClicked: root.openEdit()
                    }
                }
            }

            CopilotSourceIntakePanel {
                id: sourceIntake
                objectName: "referencePackSourceIntake"
                Layout.fillWidth: true
                Layout.fillHeight: true
                controlPlaneBridge: root.controlPlaneBridge
                sourceModel: selectedSourceModel
                hasProject: root.hasPack
                actionBusy: root.actionBusy
                feedbackMessage: root.feedbackMessage
                titleText: root.hasPack
                    ? String(root.selectedPack.title || "Reference Pack")
                    : "Chọn một Reference Pack"
                subtitleText: root.hasPack
                    ? "Revision " + String(root.selectedPack.version || 0)
                        + " · " + String(root.selectedPack.configHash || "").slice(0, 12)
                        + " · chỉ dùng dữ liệu người dùng đã nạp"
                    : "Tạo pack trước khi nạp nguồn. Browser scraping chưa bật ở giai đoạn này."
                listTitleText: "Nguồn trong pack"
                emptyText: root.hasPack
                    ? "Pack này chưa có nguồn. Nạp hàng loạt ở cột bên trái."
                    : "Chọn hoặc tạo Reference Pack để bắt đầu."
                actionText: "Thêm vào pack và xác minh"
                closeVisible: false
                onImportRequested: function(sources) {
                    root.appendSources(sources)
                }
            }
        }
    }

    Rectangle {
        id: metadataEditor
        objectName: "referencePackMetadataEditor"
        anchors.centerIn: parent
        width: Math.min(520, parent.width - 60)
        height: 330
        z: 30
        visible: root.editorOpen
        radius: Theme.radiusLarge
        color: Theme.panel
        border.width: 1
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.editingExisting
                        ? "Sửa Reference Pack" : "Tạo Reference Pack"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.Bold
                }
                AppButton {
                    text: "Đóng"
                    leadingIcon: "ui/close"
                    subtle: true
                    onClicked: root.editorOpen = false
                }
            }
            Text {
                text: "Tên pack"
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
            }
            WorkflowTextField {
                id: packTitleInput
                objectName: "referencePackTitleInput"
                Layout.fillWidth: true
                placeholderText: "Ví dụ: 10 kênh dạy tiếng Anh"
                enabled: !root.actionBusy
            }
            Text {
                text: "Mục đích và phạm vi"
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
                font.weight: Font.DemiBold
            }
            TextArea {
                id: packDescriptionInput
                objectName: "referencePackDescriptionInput"
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Pack này dùng để học điều gì, loại nguồn nào được chấp nhận?"
                wrapMode: TextArea.Wrap
                color: Theme.text
                placeholderTextColor: Theme.textFaint
                selectionColor: Theme.accent
                selectedTextColor: "white"
                font.pixelSize: Theme.fontBody
                activeFocusOnTab: true
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.elevated
                    border.width: 1
                    border.color: packDescriptionInput.activeFocus
                        ? Theme.accent : Theme.borderSoft
                }
            }
            AppButton {
                objectName: "referencePackMetadataSaveButton"
                Layout.fillWidth: true
                text: root.actionBusy ? "Đang lưu…" : "Lưu Reference Pack"
                leadingIcon: "ui/save"
                primary: true
                enabled: packTitleInput.text.trim().length > 0
                    && !root.actionBusy
                onClicked: root.saveMetadata()
            }
        }
    }
}
