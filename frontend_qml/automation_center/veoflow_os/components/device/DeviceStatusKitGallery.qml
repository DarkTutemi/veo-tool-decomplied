import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "deviceStatusKitGallery"
    width: 960
    height: 720
    color: Theme.base
    Accessible.name: "Gallery phát triển Device Status Kit"
    Accessible.role: Accessible.Pane

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        Text {
            text: "Device Status Kit · development gallery"
            color: Theme.text
            font.pixelSize: Theme.fontSection
            font.weight: Font.Bold
        }

        RowLayout {
            spacing: 18
            DeviceAvatar {
                objectName: "galleryDeviceAvatar"
                deviceId: "gallery-device"
                label: "Thiết bị mẫu"
                healthState: "healthy"
                selected: true
                hasActiveOperation: true
            }
            BatteryIndicator {
                objectName: "galleryBatteryHealthy"
                percent: 78
                charging: true
                status: "healthy"
                sampleFresh: true
            }
            BatteryIndicator {
                objectName: "galleryBatteryInvalid"
                percent: 140
                status: "healthy"
                sampleFresh: true
            }
            SignalIndicator {
                objectName: "gallerySignalHealthy"
                level: 4
                latencyMs: 32
                status: "healthy"
                sampleFresh: true
            }
            SignalIndicator {
                objectName: "gallerySignalInvalid"
                level: 7
                latencyMs: 32
                status: "healthy"
                sampleFresh: true
            }
            BatteryIndicator {
                objectName: "galleryDemoBattery"
                percent: 45
                status: "attention"
                sampleFresh: true
                provenance: "demo_seed"
                showProvenanceLabel: false
            }
            SignalIndicator {
                objectName: "galleryDemoSignal"
                level: 3
                latencyMs: 46
                status: "healthy"
                sampleFresh: true
                provenance: "simulated"
                showProvenanceLabel: false
            }
            SignalIndicator {
                objectName: "galleryPingOnly"
                level: 3
                latencyMs: 51
                status: "healthy"
                sampleFresh: true
                showBars: false
            }
        }

        RowLayout {
            spacing: 10
            StatusBadge { status: "healthy" }
            StatusBadge { status: "running" }
            StatusBadge { status: "waiting_approval"; iconName: "device/approval" }
            StatusBadge { status: "critical" }
            StatusBadge {
                objectName: "galleryUnknownStatus"
                status: "not-a-contract-state"
            }
            StatusBadge {
                objectName: "galleryDedupedDemoStatus"
                status: "demo_only"
                provenance: "demo_seed"
            }
            CodecBadge {
                objectName: "galleryDemoCodec"
                label: "POSTER"
                tone: Theme.accent
                status: "demo_only"
                provenance: "demo_seed"
                compact: true
            }
            CodecBadge {
                objectName: "galleryProductionCodecUnverified"
                label: "H.264"
                tone: Theme.success
                status: "streaming"
                authoritative: false
            }
        }

        MetricStatusRow {
            objectName: "galleryMetricStatusRow"
            Layout.preferredWidth: 480
            labelColumnWidth: 105
            valueColumnWidth: 118
            label: "Relay"
            value: "32ms"
            detail: "sample fresh"
            status: "connected"
            iconName: "device/relay"
        }
        MetricStatusRow {
            objectName: "galleryDemoMetricWithoutStatusBadge"
            Layout.preferredWidth: 480
            label: "Cast"
            value: "Poster"
            status: "demo_only"
            provenance: "demo_seed"
            showDemoBadge: false
            showStatusBadge: false
            iconName: "device/cast"
        }

        LeaseBanner {
            objectName: "galleryLeaseActive"
            Layout.preferredWidth: 520
            leaseId: "lease-gallery"
            holderLabel: "Operator demo"
            leaseState: "active"
            remainingSeconds: 540
            fencingToken: 7
            ownedByOperator: true
        }
        LeaseBanner {
            objectName: "galleryLeaseInvalid"
            Layout.preferredWidth: 520
            leaseState: "active"
            remainingSeconds: 540
            ownedByOperator: true
        }

        EvidenceStrip {
            objectName: "galleryEvidenceStrip"
            provenance: "demo_seed"
            maximumVisible: 3
            showProvenanceLabel: false
            evidenceItems: [
                {"artifactId": "artifact-shot-1", "kind": "screenshot", "verificationState": "verified", "demoThumbnailKey": "garden-creator"},
                {"artifactId": "artifact-log-2", "kind": "log", "verificationState": "pending", "demoThumbnailKey": "mountain-route"},
                {"artifactId": "artifact-result-3", "kind": "result", "verificationState": "verification_required", "demoThumbnailKey": "creator-products"},
                {"artifactId": "artifact-redacted-4", "kind": "screenshot", "verificationState": "redacted", "demoThumbnailKey": "waterfall-travel"},
                {"artifactId": "artifact-extra-5", "kind": "screenshot", "verificationState": "verified"}
            ]
        }

        Item { Layout.fillHeight: true }
    }
}
