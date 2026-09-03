import QtQuick
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"

Item {
    id: screen
    objectName: "timeMachineScreen"
    Component.onCompleted: Qt.callLater(screen.showSelectedFailure)

    // Time Machine follows the approved one-screen mockup: the shared Job Panel
    // is an invariant right rail, not an optional workspace column.
    readonly property bool showRightRail: true
    property int rightRailWidth: VfTheme.jobRailWidth
    property string actionError: ""

    function openStyleManager() {
        configSection.openStyleManagerExternal()
    }

    function openInputMediaLibrary() {
        mediaLibraryDialog.mode = "select"
        mediaLibraryDialog.launchContext = "usage_picker"
        mediaLibraryDialog.appendSelection = true
        mediaLibraryDialog.filterType = "image"
        mediaLibraryDialog.maxSelection = 9999
        mediaLibraryDialog.open()
    }

    function showSelectedFailure() {
        var job = (workspace.controller || {}).selectedJob || ({})
        if (String(job.status || "") === "failed")
            dialogs.showJobFailure(job)
    }

    function handleJobPanelAction(actionId, payload) {
        var jobId = String((payload || {}).row_id || "")
        if (actionId === "job_panel.view") {
            var view = timemachineController.jobPanelViewPayload(jobId)
            if (!(view && view.ok)) {
                screen.actionError = String(
                    (view || {}).message || "Không thể mở video."
                )
                return
            }
            var opened = nativeShell.openPath(String(view.path || ""))
            screen.actionError = opened && opened.ok
                    ? ""
                    : String((opened || {}).message
                             || "File video không còn tồn tại.")
        } else if (actionId === "job_panel.review") {
            timemachineController.setJobPanelReview(
                jobId,
                String((payload || {}).review_status || (payload || {}).status || "")
            )
            screen.actionError = ""
        } else if (actionId === "job_panel.edit") {
            var detail = timemachineController.jobPanelPromptPayload(jobId)
            if (detail && detail.ok) {
                dialogs.viewJobPrompt(detail)
                screen.actionError = ""
            } else {
                screen.actionError = String(
                    (detail || {}).message || "Không thể mở prompt clip."
                )
            }
        } else if ((actionId === "job_panel.regenerate"
                    || actionId === "job_panel.retry") && jobId.length > 0) {
            var result = timemachineController.regeneratePanelJob(jobId)
            screen.actionError = result && result.ok
                    ? ""
                    : String((result || {}).message
                             || "Không thể tạo lại clip.")
        }
    }

    Rectangle {
        anchors.fill: parent
        color: VfTheme.canvas
    }

    RowLayout {
        id: mainLayout
        objectName: "timeMachineRootLayout"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: VfTheme.dp(10)
        anchors.rightMargin: VfTheme.dp(10)
        anchors.topMargin: VfTheme.dp(10)
        anchors.bottomMargin: VfTheme.dp(10)
        spacing: VfTheme.dp(10)

        Item {
            id: mainPane
            objectName: "timeMachineMainPane"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
            clip: true

            MasterConfigPanel {
                id: configSection
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: implicitHeight
                route: "timemachine"
            }

            TimeMachineFeatureActions {
                id: featureActions
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: configSection.bottom
                anchors.topMargin: VfTheme.dp(6)
                height: implicitHeight
                controller: timemachineController

                onSubtitleStudioRequested: subtitleStudioController.openForRoute(
                    "timemachine",
                    (timemachineController.config || {}).subtitle_profile || ({}),
                    {
                        market: String((timemachineController.config || {}).market || "global"),
                        content_language: String(
                            (timemachineController.config || {}).language || "vi"),
                        aspect_ratio: String(
                            (timemachineController.config || {}).aspect_ratio
                            || "16:9"),
                        title: String(builder.intentText || "").split("\n")[0],
                        idea: String(builder.intentText || ""),
                        script: String(
                            (timemachineController.config || {}).script
                            || (timemachineController.config || {}).script_text
                            || builder.intentText || ""),
                        tone: String(
                            (timemachineController.config || {}).tone
                            || (timemachineController.config || {}).emotion
                            || ""),
                        platform: String(
                            (timemachineController.config || {}).platform
                            || "auto"),
                        content_tags: (timemachineController.config || {}).content_tags || [],
                        inherited: true
                    })
                onGraphicsStudioRequested: {
                    var config = timemachineController.config || ({})
                    var subtitleProfile = config.subtitle_profile || ({})
                    var subtitleMode = String(
                        subtitleProfile.mode || "auto").toLowerCase()
                    var subtitleEnabled = config.subtitle_enabled === undefined
                        ? true : Boolean(config.subtitle_enabled)
                    sequenceGraphicsController.openForRouteContext(
                        "timemachine",
                        config.sequence_graphics || ({}),
                        {
                            enabled: subtitleEnabled && subtitleMode !== "off",
                            profile: subtitleProfile,
                            has_external_srt: false,
                            aspect_ratio: String(config.aspect_ratio || "16:9"),
                            timeline_reserved: true
                        })
                }
            }

            TimeMachineJobBuilder {
                id: builder
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: featureActions.bottom
                anchors.topMargin: VfTheme.dp(8)
                height: implicitHeight
                controller: timemachineController
                onActionError: function(message) {
                    screen.actionError = message
                }
                onMediaLibraryRequested: screen.openInputMediaLibrary()
            }

            TimeMachineWorkspaceFrame {
                id: workspace
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: builder.bottom
                anchors.topMargin: VfTheme.dp(8)
                anchors.bottom: parent.bottom
                controller: timemachineController
                actionError: screen.actionError
                draftPrepared: builder.draftPrepared
                inputImageCount: builder.imageCount

                onEnqueueRequested: builder.enqueue()
                onEditStageRequested: function(stageIdx, name, visibleDescription) {
                    dialogs.editStage(stageIdx, name, visibleDescription)
                }
                onEditCellRequested: function(viewId, viewLabel, stageIdx, prompt, locked) {
                    dialogs.editCell(viewId, viewLabel, stageIdx, prompt, locked)
                }
                onEditMotionRequested: function(motionKey, viewLabel, fromStage, toStage, prompt) {
                    dialogs.editMotion(motionKey, viewLabel, fromStage, toStage, prompt)
                }
                onOpenFolderRequested: function(folder) {
                    if (String(folder || "").length > 0)
                        nativeShell.openPath(String(folder))
                }
            }
        }

        Rectangle {
            id: rightRail
            objectName: "timeMachineRightRail"
            Layout.preferredWidth: screen.rightRailWidth
            Layout.minimumWidth: screen.rightRailWidth
            Layout.maximumWidth: screen.rightRailWidth
            Layout.fillHeight: true
            visible: true
            color: VfTheme.surfaceSoft
            radius: VfTheme.radiusPanel
            border.color: VfTheme.borderBox
            border.width: 1
            clip: true
            z: 100

            JobPanelWidget {
                id: jobPanel
                anchors.fill: parent
                anchors.margins: 1
                jobModel: timemachineController.jobPanelModel
                rows: timemachineController.jobPanelRows
                stats: ({})
                route: "timemachine"
                autoPageSize: true
                onActionRequested: function(actionId, payload) {
                    screen.handleJobPanelAction(actionId, payload)
                }
            }
        }
    }

    TimeMachineDialogs {
        id: dialogs
        anchors.fill: parent
        controller: timemachineController
        onJobPromptRegenerateRequested: function(jobId) {
            dialogs.applyJobPromptRegenerateResult(
                timemachineController.regeneratePanelJob(jobId)
            )
        }
        onActionError: function(message) {
            screen.actionError = message
        }
        onFailedJobRetryRequested: function(jobId) {
            var result = dialogs.controller.resumeJob(jobId)
            screen.actionError = result && result.ok
                    ? ""
                    : String((result || {}).message
                             || "Không thể thử lại job.")
        }
        onFailedJobFolderRequested: function(folder) {
            workspace.openFolderRequested(String(folder || ""))
        }
    }

    Connections {
        target: workspace.controller
        function onSelectionChanged() {
            Qt.callLater(screen.showSelectedFailure)
        }
    }

    MediaLibraryDialog {
        id: mediaLibraryDialog
        items: visible ? workPanelController.mediaLibraryItems : []
        stats: workPanelController.mediaLibraryStats
        settings: workPanelController.mediaLibrarySettings
        onRefreshRequested: (search, assetType) =>
            workPanelController.refreshMediaLibrary(search, assetType)
        onMediaSelected: selection => {
            mediaLibraryDialog.applySelectionResult(
                builder.addMediaSelection(selection))
        }
    }

}
