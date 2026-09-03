import QtQuick

Image {
    id: root
    property string platform: "generic"

    width: 18
    height: 18
    sourceSize.width: 48
    sourceSize.height: 48
    fillMode: Image.PreserveAspectFit
    smooth: true
    mipmap: true
    asynchronous: false
    source: Qt.resolvedUrl("../assets/social/" + fileName)

    readonly property string fileName: {
        switch (platform.toLowerCase()) {
        case "youtube": return "youtube.svg"
        case "tiktok": return "tiktok.svg"
        case "facebook": return "facebook.svg"
        case "instagram": return "instagram.svg"
        case "x": return "x.svg"
        case "linkedin": return "linkedin.svg"
        default: return "generic.svg"
        }
    }
}
