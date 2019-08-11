import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12

import "service.js" as Service
import "sdk.js" as SDK

ApplicationWindow {
    id: window
    visible: true
    width: 1920
    height: 1080
    title: qsTr("Forecast")
    visibility: Window.FullScreen

    // theme settings
    Material.theme: Material.Dark
    Material.accent: Material.BlueGrey

    // properties
    readonly property var citiesModel: ["Amsterdam", "Venice", "Prague", "Lisbon","London", "Paris", "Berlin", "Zagreb", "Vienna"]
    readonly property string currentCity: citiesModel[cityList.currentIndex]
    readonly property var currentWeather: weatherModel[weatherList.currentIndex]
    property var weatherModel: []

    function updateCity(city) {
        Service.getForecast(city)
            .then(data => weatherModel = data.list)
            .catch(error => console.error(error.code, error.msg))
    }

    RowLayout {
        anchors.fill: parent

        ListView {
            id: cityList
            focus: true
            Layout.preferredWidth: 400
            Layout.fillHeight: true

            highlightFollowsCurrentItem: true
            highlightMoveDuration: 250

            // delay city data update
            onCurrentIndexChanged: updateModelTimer.restart()

            model: citiesModel

            keyNavigationWraps: true

            KeyNavigation.right: weatherList

            delegate: Button {
                width: cityList.width
                height: cityList.height / 7
                font.pixelSize: 32
                highlighted: activeFocus && ListView.isCurrentItem
                text: modelData
            }

            Timer {
                id: updateModelTimer
                interval: 300
                onTriggered: updateCity(currentCity)
            }
        }

        // right pane
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 50
            spacing: 100

            Column {
                width: parent.width
                spacing: 30

                Label {
                    id: date
                    font.pixelSize: 40

                    Timer {
                        running: Qt.application.state === Qt.ApplicationActive
                        interval: 5000
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: date.text = Qt.formatDate(new Date(), Qt.SystemLocaleLongDate)
                    }
                }

                Label {
                    id: city
                    font.pixelSize: 30
                    text: currentCity
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 100

                Column {
                    spacing: 30

                    Label {
                        font.pixelSize: 30
                        text: currentWeather.weather[0].main
                    }

                    Image {
                        width: 100
                        height: 100
                        smooth: true
                        fillMode: Image.PreserveAspectFit
                        source: Service.getIconUrl(currentWeather.weather[0].icon)
                    }

                    Label {
                        font.pixelSize: 30
                        text: SDK.temperatureToString(currentWeather.temp.day)
                    }
                }

                Column {
                    spacing: 30

                    Label {
                        font.pixelSize: 30
                        text: qsTr("Humidity") + `: ${currentWeather.humidity} %`
                    }

                    Label {
                        font.pixelSize: 30
                        text: qsTr("Wind") + `: ${currentWeather.speed} km/h`
                    }
                }
            }

            ListView {
                id: weatherList
                Layout.fillWidth: true
                Layout.preferredHeight: contentItem.childrenRect.height

                orientation: Qt.Horizontal

                highlightFollowsCurrentItem: true
                highlightMoveDuration: 250
                highlight: Rectangle { visible: weatherList.activeFocus; color: Material.accent }

                model: weatherModel

                Keys.onUpPressed: { cityList.decrementCurrentIndex(); cityList.focus = true }
                Keys.onDownPressed: { cityList.incrementCurrentIndex(); cityList.focus = true }

                delegate: ColumnLayout {
                    readonly property var weather: modelData.weather[0]
                    readonly property var temp: modelData.temp
                    readonly property int timestamp: modelData.dt

                    width: weatherList.width / 7
                    spacing: 80

                    Label {
                        font.pixelSize: 26
                        text: SDK.timpestampToDay(timestamp)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Image {
                        source: Service.getIconUrl(weather.icon)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        font.pixelSize: 26
                        text: SDK.temperatureToString(temp.day)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
