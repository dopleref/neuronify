import QtQuick 2.5
import QtCharts 2.1
import Neuronify 1.0

import ".."
import "../controls"
import "../edges"
import "../hud"
import "../paths"
import "../tools"
import "../style"

/*!
\qmltype RasterPlot
\inqmlmodule Neuronify
\ingroup neuronify-meters
\brief Shows firing times of neurons.
*/


Node {
    id: rasterRoot

    property real time: 0.0
    property real timeRange: 100.0e-3
    property real timeScale: 1e-3
    property bool showLegend: true

    property var neurons: []

    property real realTime: 0.0
    property real timeSinceLastUpdate: 0
    property real lastUpdateTime: 0
    property real maximumPointCount: 120
    property int numberOfEdges: 0


    objectName: "rasterplot"
    filename: "meters/RasterPlot.qml"
    square: true

    width: 320
    height: 240
    color: "#deebf7"

    canReceiveConnections: false

    preferredEdge: MeterEdge {}

    savedProperties: PropertyGroup {
        property alias width: rasterRoot.width
        property alias height: rasterRoot.height
        property alias timeRange: rasterRoot.timeRange
        property alias showLegend: rasterRoot.showLegend
    }

    engine: NodeEngine {
        onStepped: {
            if((realTime - lastUpdateTime) > timeRange / maximumPointCount) {
                time = realTime
                lastUpdateTime = realTime
            }
            realTime += dt
        }
    }

    controls: Component {
       PropertiesPage {
           property string title: "Raster plot"
            BoundSlider {
                target: rasterRoot
                property: "timeRange"
                text: "Time range"
                unit: "ms"
                unitScale: 1e-3
                minimumValue: 1.0e-3
                maximumValue: 1000.0e-3
                stepSize: 10.0e-3

                ConnectMultipleControl {
                    toEnabled: false
                    node: rasterRoot
                }

                ResetControl {
                    engine: rasterRoot.engine
                }
            }
        }
    }

    function refreshCategories() {
        var toRemove = []
        for(var i in axisY.categoriesLabels) {
            toRemove.push(axisY.categoriesLabels[i])
        }
        for(var i in toRemove) {
            var label = toRemove[i]
            axisY.remove(label)
        }
        for(var i in neurons) {
            var neuron = neurons[i]
            var position = parseFloat(i) + 1.5
            axisY.append(" " + neuron.label, position)
        }
    }

    onEdgeAdded: {
        numberOfEdges +=1
        var neuron = edge.itemB
        var newList = neurons
        neurons.push(neuron)
        neuron.onLabelChanged.connect(refreshCategories)
        neuron.fired.connect(function() {
            for(var i in neurons) {
                var neuron2 = neurons[i]
                if(neuron2 === neuron) {
                    scroller.append(time / timeScale, parseFloat(i) + 1.0)
                }
            }
        });
        neurons = newList

        refreshCategories()
    }

    onEdgeRemoved: {
        numberOfEdges -=1
        var neuron = edge.itemB
        console.log(neuron)
        var newList = neurons
        var index = newList.indexOf(neuron)
        console.log("Index " + index)
        if(index > -1) {
            newList.splice(index, 1)
            neurons = newList
        }
        neuron.onLabelChanged.disconnect(refreshCategories)

        scatterSeries.clear()
        refreshCategories()
    }

    Rectangle {
        anchors.fill: parent
        color: parent.color
        border.color: Style.meter.border.color
        border.width: Style.meter.border.width
        smooth: true
        antialiasing: true
    }

    ChartView {
        anchors.fill: parent
        enabled: false // disable mouse input
        legend.visible: false
        backgroundColor: "transparent"

        margins.top: 0
        margins.bottom: 0
        margins.left: 0
        margins.right: 0

        ScatterSeries {
            id: scatterSeries
            useOpenGL: false // TODO use OpenGL once points are bigger again
            borderWidth: 0.2
            markerSize: 8.0
            axisX: ValueAxis {
                id: axisX
                min: (time - timeRange) / timeScale
                max: time / timeScale
                tickCount: 2
                gridVisible: false
                labelsFont.pixelSize: 14
                labelFormat: "%.0f"
                titleFont.weight: Font.Normal
                titleFont.pixelSize: 14
                titleText: rasterRoot.showLegend ? "t [ms]" : ""
            }
            axisY: CategoryAxis {
                id: axisY
                min: 0.0
                max: neurons.length + 1.0
                startValue: 0.5
                gridVisible: false
                tickCount: 0
                lineVisible: false
                labelsFont.pixelSize: 14
                titleFont.weight: Font.Normal
                titleFont.pixelSize: 14
                //                titleText: rasterRoot.showLegend ? "Cell" : ""
            }
        }
        ChartScroller {
            id: scroller
            series: scatterSeries
            timeRange: rasterRoot.timeRange / rasterRoot.timeScale
        }
    }

    ResizeRectangle {}

    Connector {
        color: Style.meter.border.color
        visible: parent.selected ||  numberOfEdges < 1
    }
}
