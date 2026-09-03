pragma Singleton

import QtQuick

QtObject {
    function _num(value, fallback) {
        var numberValue = Number(value)
        return isNaN(numberValue) ? Number(fallback || 0) : numberValue
    }

    function _clearance(value) {
        return Math.max(0, _num(value, 48))
    }

    function width(parentItem, maxWidth, clearance) {
        var cap = Math.max(1, _num(maxWidth, 720))
        if (!parentItem)
            return cap
        var available = _num(parentItem.width, cap) - _clearance(clearance)
        return Math.max(1, Math.min(cap, available > 0 ? available : _num(parentItem.width, cap)))
    }

    function height(parentItem, maxHeight, clearance) {
        var cap = Math.max(1, _num(maxHeight, 560))
        if (!parentItem)
            return cap
        var available = _num(parentItem.height, cap) - _clearance(clearance)
        return Math.max(1, Math.min(cap, available > 0 ? available : _num(parentItem.height, cap)))
    }

    function centerX(parentItem, dialogWidth) {
        if (!parentItem)
            return 0
        return Math.max(0, Math.round((_num(parentItem.width, dialogWidth) - _num(dialogWidth, 0)) / 2))
    }

    function centerY(parentItem, dialogHeight) {
        if (!parentItem)
            return 0
        return Math.max(0, Math.round((_num(parentItem.height, dialogHeight) - _num(dialogHeight, 0)) / 2))
    }

    function compact(dialogWidth, dialogHeight) {
        return _num(dialogWidth, 0) < 980 || _num(dialogHeight, 0) < 640
    }

    function tight(dialogWidth, dialogHeight) {
        return _num(dialogWidth, 0) < 760 || _num(dialogHeight, 0) < 520
    }
}
