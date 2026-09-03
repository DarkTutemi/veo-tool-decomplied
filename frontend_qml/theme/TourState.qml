pragma Singleton

import QtQuick

// App-wide tour state, readable from any screen (screens already import "theme").
// While `preview` is true, a guided tour is running on a REAL tab and the tab's
// data-heavy widgets (queue table, job panel...) swap their controller bindings
// for BAKED sample data (see components/TourPreviewData.js) so an empty first-run
// demo looks alive. App.qml flips it on at tour start and off at tour end.
QtObject {
    property bool preview: false
    // Which route's tour is running (for tabs that want route-specific fake data).
    property string route: ""
}
