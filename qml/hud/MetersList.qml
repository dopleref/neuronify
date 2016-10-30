import QtQuick 2.0

ListModel {
    ListElement {
        name: "Voltmeter"
        description: "Measures the membrane potential of neurons"
        source: "../meters/Voltmeter.qml"
        imageSource: "qrc:/images/meters/voltmeter.png"
    }
    ListElement {
        name: "Raster plot"
        description: "Shows firing times of neurons"
        source: "../meters/RasterPlot.qml"
        imageSource: "qrc:/images/meters/spikemeter.png"
    }
    ListElement {
        name: "Firing rate plot"
        description: "Shows firing rate of neurons"
        source: "../meters/RatePlot.qml"
        imageSource: "qrc:/images/meters/ratePlot.png"
    }
    ListElement {
        name: "Loudspeaker"
        description: "Plays a sound when a connected neuron fires"
        source: "../meters/Loudspeaker.qml"
        imageSource: "qrc:/images/meters/loudspeaker.png"
    }
}
