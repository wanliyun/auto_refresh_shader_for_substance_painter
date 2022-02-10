// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.5
import QtQml 2.2
import QtQml.Models 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import AlgWidgets 2.0
import AlgWidgets.Style 2.0

AlgDialog
{
  id: root;
  visible: false;
  title: "Autoupdate configuration";
  width: 400;
  height: 280;
  minimumWidth: width;
  minimumHeight: height;
  maximumWidth: width;
  maximumHeight: height;

  signal configurationChanged(
    int interval)

  onVisibleChanged: {
    if (visible) internal.initModel()
  }

  Component.onCompleted: {
    internal.initModel()
    internal.emit()
  }

  onAccepted: internal.emit()

  QtObject {
    id: internal
    readonly property string intervalKey:           "autoUpdateInterval"
    readonly property int intervalDefault:          1
    readonly property int intervalMax:              120

    property var settings: ({})

    function newModelComponent(label, min_value, max_value, default_value, settings_name) {
      return {
        "label": label,
        "min_value": min_value,
        "max_value": max_value,
        "default_value": default_value,
        "settings_name": settings_name
      }
    }

    function initModel() {
      reinitSettings()
      model.clear()
      model.append(
        newModelComponent(
          "Autoupdate interval in seconds:",
          0,
          intervalMax,
          intervalDefault,
          intervalKey))
    }

    function reinitSettings() {
      updateSettings(intervalKey, alg.settings.value(intervalKey, intervalDefault))
    }

    function updateSettings(settings_name, value) {
      settings[settings_name] = value
    }

    function emit() {
      alg.settings.setValue(intervalKey, settings[intervalKey])
      alg.log.info("emit" + settings[intervalKey])
      configurationChanged(
        settings[intervalKey] * 1)
    }
  }


 AlgScrollView {
    id: scrollView;
    parent: root.contentItem
    anchors.fill: parent
    anchors.margins: 16

    ColumnLayout {
      Layout.preferredWidth: scrollView.viewportWidth
      spacing: AlgStyle.defaultSpacing

      Repeater {
        id: layoutInstantiator

        model: ListModel {
          id: model
        }

        delegate: AlgSlider {
          id: slider
          text: label
          minValue: min_value
          maxValue: max_value
          value: alg.settings.value(settings_name, default_value)
          // integers only
          stepSize: 1
          precision: 0
          Layout.fillWidth: true
          onRoundValueChanged: internal.updateSettings(settings_name, roundValue)
        }
      }
    }
  }
}
