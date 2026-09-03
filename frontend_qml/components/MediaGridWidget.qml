import QtQuick
import QtQuick.Controls

import "../theme"

Item {
    id: root

    property var items: []
    property string selectedId: ""
    property var selectedIds: []
    property int maxSelection: 1
    property int cardWidth: 168
    property int cardHeight: 216
    property int gridSpacing: 12
    property int lazyPreloadRows: 1
    property string filterType: ""
    property bool managementMode: true
    property var selectedLookup: ({})
    // Law 3: model-with-identity. Gán thẳng JS array làm model khiến GridView đập
    // toàn bộ delegate mỗi lần refresh (import 1 ảnh = cả grid nháy + scroll về đầu).
    // Reconcile diff theo media id vào ListModel: chỉ row thêm/bớt bị đụng.
    property var _mediaById: ({})

    signal mediaSelected(var media)
    signal selectionChanged(var selectedIds)
    signal mediaDoubleClicked(var media)
    signal mediaEditRequested(var media)
    signal mediaRenameRequested(var media)
    signal mediaTypeChanged(var media, string assetType)
    signal mediaPreviewRequested(var media)
    signal mediaOpenRequested(var media)
    signal mediaRemoveRequested(var media)

    function mediaId(media) {
        return String(media.id || media.media_id || "")
    }

    function currentSelectedIds() {
        var ids = root.selectedIds || []
        if (ids.length > 0)
            return ids
        if (root.selectedId.length > 0)
            return [root.selectedId]
        return []
    }

    function rebuildSelectedLookup() {
        var lookup = ({})
        var ids = root.currentSelectedIds()
        for (var i = 0; i < ids.length; i++) {
            var id = String(ids[i] || "")
            if (id.length > 0)
                lookup[id] = true
        }
        root.selectedLookup = lookup
    }

    function isSelected(media) {
        var mid = root.mediaId(media)
        if (mid.length === 0)
            return false
        return Boolean((root.selectedLookup || ({}))[mid])
    }

    function commitSelection(ids) {
        var next = ids || []
        root.selectedIds = next.slice(0)
        root.selectedId = next.length > 0 ? String(next[0]) : ""
        root.rebuildSelectedLookup()
        root.selectionChanged(root.selectedIds)
    }

    function toggleSelection(media) {
        var id = root.mediaId(media)
        if (id.length === 0)
            return

        var ids = root.currentSelectedIds()
        var at = ids.indexOf(id)
        if (at >= 0) {
            ids.splice(at, 1)
        } else if (root.maxSelection === 0 || ids.length < root.maxSelection) {
            ids.push(id)
        } else if (root.maxSelection === 1) {
            ids = [id]
        } else {
            ids.shift()
            ids.push(id)
        }

        root.commitSelection(ids)
    }

    function _reconcileModel() {
        var list = root.items || []
        var byId = ({})
        var order = []
        for (var i = 0; i < list.length; i++) {
            var item = list[i] || ({})
            var mid = root.mediaId(item)
            if (mid.length === 0 || byId[mid] !== undefined)
                mid = (mid.length > 0 ? mid : "__row") + "__" + i
            byId[mid] = item
            order.push(mid)
        }
        // Gán map trước khi sửa model: delegate của row giữ lại rebind sang data mới
        // ngay trong cùng stack JS (chưa render frame nào ở giữa nên không nháy).
        root._mediaById = byId
        var want = ({})
        for (var w = 0; w < order.length; w++)
            want[order[w]] = true
        for (var r = gridModel.count - 1; r >= 0; r--) {
            if (want[gridModel.get(r).mid] !== true)
                gridModel.remove(r)
        }
        for (var j = 0; j < order.length; j++) {
            if (j < gridModel.count && gridModel.get(j).mid === order[j])
                continue
            var found = -1
            for (var k = j + 1; k < gridModel.count; k++) {
                if (gridModel.get(k).mid === order[j]) {
                    found = k
                    break
                }
            }
            if (found >= 0)
                gridModel.move(found, j, 1)
            else
                gridModel.insert(j, { mid: order[j] })
        }
    }

    onItemsChanged: root._reconcileModel()
    onSelectedIdChanged: root.rebuildSelectedLookup()
    onSelectedIdsChanged: root.rebuildSelectedLookup()
    Component.onCompleted: {
        root.rebuildSelectedLookup()
        root._reconcileModel()
    }

    ListModel {
        id: gridModel
    }

    function clearSelection() {
        root.commitSelection([])
    }

    function selectAll() {
        var ids = []
        var list = root.items || []
        for (var i = 0; i < list.length; i++) {
            var id = root.mediaId(list[i])
            if (id.length > 0)
                ids.push(id)
            if (root.maxSelection > 0 && ids.length >= root.maxSelection)
                break
        }
        root.commitSelection(ids)
    }

    GridView {
        id: gridView
        anchors.fill: parent
        clip: true
        reuseItems: true
        model: gridModel

        property int _cols: Math.min(8, Math.max(1, Math.floor(Math.max(1, width) / (root.cardWidth + root.gridSpacing))))
        cellWidth: Math.max(root.cardWidth + root.gridSpacing, Math.floor(width / _cols))
        cellHeight: root.cardHeight + root.gridSpacing

        cacheBuffer: cellHeight * Math.max(0, root.lazyPreloadRows)

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        delegate: Item {
            id: delegateRoot
            width: gridView.cellWidth
            height: gridView.cellHeight
            readonly property var mediaData: root._mediaById[model.mid] || ({})
            readonly property bool shouldLoadImage: (
                y + height >= gridView.contentY - (gridView.cellHeight * Math.max(0, root.lazyPreloadRows))
                && y <= gridView.contentY + gridView.height + (gridView.cellHeight * Math.max(0, root.lazyPreloadRows))
            )

            MediaCard {
                anchors.fill: parent
                anchors.margins: root.gridSpacing / 2
                cardWidth: root.cardWidth
                cardHeight: root.cardHeight
                loadImage: delegateRoot.shouldLoadImage
                media: delegateRoot.mediaData
                filterType: root.filterType
                managementMode: root.managementMode
                selected: root.isSelected(delegateRoot.mediaData)
                onClicked: media => {
                    root.toggleSelection(media)
                    root.mediaSelected(media)
                }
                onDoubleClicked: media => root.mediaDoubleClicked(media)
                onEditRequested: media => root.mediaEditRequested(media)
                onRenameRequested: media => root.mediaRenameRequested(media)
                onTypeChanged: (media, assetType) => root.mediaTypeChanged(media, assetType)
                onPreviewRequested: media => root.mediaPreviewRequested(media)
                onOpenRequested: media => root.mediaOpenRequested(media)
                onRemoveRequested: media => root.mediaRemoveRequested(media)
            }
        }
    }
}
