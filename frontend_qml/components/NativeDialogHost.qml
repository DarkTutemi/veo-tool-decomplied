import QtQuick
import QtQuick.Dialogs

Item {
    id: root

    property var activeRequest: ({})

    Connections {
        target: nativeShell
        function onFileDialogRequested(request) {
            root.openRequest(request || ({}))
        }
    }

    FileDialog {
        id: fileDialog
        title: String(root.activeRequest.title || "Select Files")
        fileMode: FileDialog.OpenFiles
        nameFilters: root.filterList(root.activeRequest)

        onAccepted: root.acceptFileDialog()
        onRejected: root.cancelDialog()
    }

    FolderDialog {
        id: folderDialog
        title: String(root.activeRequest.title || "Select Folder")

        onAccepted: {
            nativeShell.completeFileDialogRequest(
                root.requestId(),
                {
                    ok: true,
                    cancelled: false,
                    path: String(folderDialog.selectedFolder || ""),
                    paths: [String(folderDialog.selectedFolder || "")]
                }
            )
            root.activeRequest = ({})
        }
        onRejected: root.cancelDialog()
    }

    function openRequest(request) {
        root.activeRequest = request || ({})
        var kind = String(root.activeRequest.kind || "open_files")
        if (kind === "folder") {
            if (String(root.activeRequest.start_url || "").length > 0)
                folderDialog.currentFolder = root.activeRequest.start_url
            folderDialog.open()
            return
        }

        fileDialog.fileMode = kind === "save_text" ? FileDialog.SaveFile : FileDialog.OpenFiles
        fileDialog.nameFilters = root.filterList(root.activeRequest)
        if (String(root.activeRequest.start_url || "").length > 0)
            fileDialog.currentFolder = root.activeRequest.start_url
        if (kind === "save_text" && String(root.activeRequest.default_url || "").length > 0)
            fileDialog.currentFile = root.activeRequest.default_url
        fileDialog.open()
    }

    function acceptFileDialog() {
        var paths = []
        var kind = String(root.activeRequest.kind || "open_files")
        if (kind === "save_text") {
            paths = [String(fileDialog.selectedFile || "")]
        } else {
            for (var i = 0; i < fileDialog.selectedFiles.length; i++)
                paths.push(String(fileDialog.selectedFiles[i] || ""))
        }
        nativeShell.completeFileDialogRequest(
            root.requestId(),
            {
                ok: paths.length > 0 && paths[0].length > 0,
                cancelled: paths.length === 0 || paths[0].length === 0,
                path: paths.length > 0 ? paths[0] : "",
                paths: paths,
                selected_filter: root.selectedFilterText()
            }
        )
        root.activeRequest = ({})
    }

    function cancelDialog() {
        nativeShell.completeFileDialogRequest(
            root.requestId(),
            {
                ok: false,
                cancelled: true,
                path: "",
                paths: [],
                selected_filter: root.selectedFilterText()
            }
        )
        root.activeRequest = ({})
    }

    function requestId() {
        return String(root.activeRequest.request_id || "")
    }

    function filterList(request) {
        var filters = request.name_filters || []
        if (filters.length > 0)
            return filters
        return ["All Files (*)"]
    }

    function selectedFilterText() {
        var selected = fileDialog.selectedNameFilter
        if (selected === undefined || selected === null)
            return ""
        if (typeof selected === "string")
            return selected
        if (selected.name !== undefined)
            return String(selected.name || "")
        if (selected.globs !== undefined)
            return String(selected.globs || "")
        return String(selected || "")
    }
}
