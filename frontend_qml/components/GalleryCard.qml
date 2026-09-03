import QtQuick

MediaCard {
    id: root

    property string imageId: String(media.id || media.image_id || "")
    property string prompt: String(media.prompt || "")
}
