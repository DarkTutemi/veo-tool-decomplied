pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "deviceEnrollmentWizard"
    property var readiness: ({})
    property int currentStep: 0
    readonly property var steps: (root.readiness || {}).steps || []
    readonly property int stepCount: root.steps.length
    readonly property var currentStepData: root.stepAt(root.currentStep)
    readonly property var identityAuthority: (root.readiness || {}).identity_authority || ({})
    readonly property bool executable: Boolean((root.readiness || {}).executable)
    // A future backend may make readiness executable, but this UI still stays
    // disabled until a dedicated enrollment command contract is wired.
    readonly property bool enrollmentCommandAvailable: false
    signal closeRequested()
    signal refreshRequested()
    Accessible.name: "Trình hướng dẫn enrollment thiết bị"
    Accessible.description: String((root.readiness || {}).summary || "Không có readiness từ server")
    Accessible.role: Accessible.Dialog

    function stepAt(index) {
        const bounded = Math.max(0, Math.min(root.stepCount - 1, Number(index)))
        return root.stepCount > 0 ? root.steps[bounded] || ({}) : ({})
    }

    function selectStep(index) {
        if (root.stepCount === 0) return false
        root.currentStep = Math.max(0, Math.min(root.stepCount - 1, Number(index)))
        return true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "Thêm thiết bị"; color: Theme.text; font.pixelSize: 21; font.weight: Font.Bold }
                Text {
                    Layout.fillWidth: true
                    text: "Readiness và blocker do Python control plane cung cấp"
                    color: Theme.textFaint
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }
            Foundation.StatusPill {
                text: root.executable ? "Có thể thực thi" : "Chỉ kiểm tra điều kiện"
                tone: root.executable ? Theme.success : Theme.warning
                showDot: true
            }
            Foundation.IconButton {
                objectName: "deviceEnrollmentCloseButton"
                text: ""
                iconName: "ui/close"
                accessibleName: "Đóng trình enrollment"
                activeFocusOnTab: true
                onClicked: root.closeRequested()
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ListView {
                id: stepList
                objectName: "deviceEnrollmentStepList"
                Layout.preferredWidth: 310
                Layout.fillHeight: true
                model: root.steps
                spacing: 5
                clip: true
                reuseItems: true
                Accessible.name: "Mười bước enrollment"
                Accessible.role: Accessible.List

                delegate: Button {
                    id: stepButton
                    required property int index
                    required property var modelData
                    objectName: "deviceEnrollmentStep_" + String(stepButton.modelData.key || index)
                    width: stepList.width
                    height: 52
                    activeFocusOnTab: true
                    Accessible.name: "Bước " + String(stepButton.modelData.sequence || index + 1)
                        + ", " + String(stepButton.modelData.title || "Không rõ")
                    Accessible.description: String(stepButton.modelData.reason || "Không có lý do")
                    Accessible.role: Accessible.ListItem
                    onClicked: root.selectStep(index)
                    contentItem: RowLayout {
                        spacing: 8
                        Rectangle {
                            Layout.preferredWidth: 28; Layout.preferredHeight: 28; radius: 14
                            color: stepButton.index === root.currentStep ? Theme.accentSoft : Theme.elevated
                            border.width: 1
                            border.color: stepButton.index === root.currentStep ? Theme.accent : Theme.borderSoft
                            Text { anchors.centerIn: parent; text: String(stepButton.modelData.sequence || stepButton.index + 1); color: Theme.text; font.pixelSize: 11; font.weight: Font.Bold }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { Layout.fillWidth: true; text: String(stepButton.modelData.title || "Không rõ"); color: Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { Layout.fillWidth: true; text: String(stepButton.modelData.detail_code || "SOURCE_UNAVAILABLE"); color: Theme.warning; font.pixelSize: 10; elide: Text.ElideRight }
                        }
                    }
                    background: Rectangle {
                        radius: Theme.radiusSmall
                        color: stepButton.index === root.currentStep ? Theme.accentSoft : Theme.elevated
                        border.width: 1
                        border.color: stepButton.index === root.currentStep ? Theme.accent : Theme.borderSoft
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: "Bước " + String(root.currentStepData.sequence || "—")
                            + " · " + String(root.currentStepData.title || "Không có dữ liệu")
                        color: Theme.text
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        wrapMode: Text.Wrap
                    }
                    Foundation.StatusPill {
                        text: String(root.currentStepData.state || "unavailable")
                        tone: String(root.currentStepData.state || "") === "ready" ? Theme.success : Theme.warning
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 12
                        rowSpacing: 8
                        Text { text: "Nguồn"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { Layout.fillWidth: true; text: String(root.currentStepData.source || "Không khả dụng"); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideMiddle }
                        Text { text: "Mã"; color: Theme.textFaint; font.pixelSize: 11 }
                        Text { Layout.fillWidth: true; text: String(root.currentStepData.detail_code || "Không khả dụng"); color: Theme.warning; font.pixelSize: 11; elide: Text.ElideMiddle }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String(root.currentStepData.reason || "Backend chưa cung cấp lý do readiness.")
                        color: Theme.textMuted
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                    Rectangle {
                        id: identityCard
                        objectName: "deviceEnrollmentIdentityAuthority"
                        Layout.fillWidth: true
                        Layout.preferredHeight: identityColumn.implicitHeight + 20
                        radius: Theme.radiusSmall
                        color: Theme.accentSoft
                        border.width: 1
                        border.color: Theme.accent
                        Accessible.name: "Định danh thiết bị do server cấp"
                        Accessible.description: String(root.identityAuthority.summary || "Không có identity contract")
                        Accessible.role: Accessible.StaticText

                        ColumnLayout {
                            id: identityColumn
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5
                            Text {
                                Layout.fillWidth: true
                                text: "ĐỊNH DANH THIẾT BỊ · SERVER-OWNED"
                                color: Theme.accent
                                font.pixelSize: 10
                                font.weight: Font.Bold
                            }
                            Text {
                                objectName: "deviceEnrollmentIdentitySummary"
                                Layout.fillWidth: true
                                text: String(root.identityAuthority.summary || "Control plane chưa công bố identity contract.")
                                color: Theme.text
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Text {
                                    Layout.fillWidth: true
                                    text: "Format: " + String(root.identityAuthority.device_id_format || "—")
                                    color: Theme.textMuted
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                                Foundation.StatusPill {
                                    text: root.identityAuthority.client_assignable === false
                                        ? "Client không được tự gán" : "Không rõ authority"
                                    tone: root.identityAuthority.client_assignable === false
                                        ? Theme.success : Theme.warning
                                    showDot: true
                                }
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }
                    Text { text: "Metadata editor"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Text {
                        Layout.fillWidth: true
                        text: String(((root.readiness || {}).metadata_editor || {}).reason
                            || "Editor bị khóa cho tới khi có device identity do server cấp.")
                        color: Theme.warning
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: String((root.readiness || {}).summary || "Không có readiness summary")
                        color: Theme.textFaint
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            AppButton {
                objectName: "deviceEnrollmentPreviousButton"
                text: "Bước trước"
                activeFocusOnTab: true
                enabled: root.currentStep > 0
                Accessible.name: text
                onClicked: root.selectStep(root.currentStep - 1)
            }
            AppButton {
                objectName: "deviceEnrollmentNextButton"
                text: "Bước tiếp"
                activeFocusOnTab: true
                enabled: root.currentStep + 1 < root.stepCount
                Accessible.name: text
                onClicked: root.selectStep(root.currentStep + 1)
            }
            Item { Layout.fillWidth: true }
            AppButton {
                objectName: "deviceEnrollmentRefreshButton"
                text: "Làm mới readiness"
                activeFocusOnTab: true
                Accessible.name: text
                Accessible.description: "Chỉ tải lại phone_farm.snapshot"
                onClicked: root.refreshRequested()
            }
            AppButton {
                objectName: "deviceEnrollmentExecuteButton"
                text: "Bắt đầu enrollment"
                primary: true
                activeFocusOnTab: true
                enabled: root.executable && root.enrollmentCommandAvailable
                Accessible.name: text
                Accessible.description: enabled
                    ? "Bắt đầu bằng capability enrollment chuyên dụng"
                    : "Bị khóa: chưa có bootstrap, signed runtime, enrollment và gateway contracts"
            }
        }
    }
}
