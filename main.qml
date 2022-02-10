// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.7
import Painter 1.0

PainterPlugin
{
  QtObject {
    id: internal
    property int intervalTime : 10
    property int remainingTime : -1
    property bool projectOpen: alg.project.isOpen()
    onProjectOpenChanged: {
      if (projectOpen) {
        reinitRemainingTime()
        timer.start()
      }
      else timer.stop()
    }

    function updateShaders() {
      //alg.log.info("Auto update shader...");
      alg.shaders.instances().forEach(function(shader) {
        var shaderResoruce = alg.resources.importProjectResource("D:/sp/shader/DH-Toon.glsl", "shader")
        if(shader.shader == "DH-Toon" && shader.url != shaderResoruce)
        {
           alg.log.info(shader.label + ": " + shader.id + ":" + shader.shader + ":" + shader.url);
           alg.shaders.updateShaderInstance(shader.id, shaderResoruce);
        }
     });
    }
    function reinitRemainingTime(){
      if(intervalTime > 0 && intervalTime)
        remainingTime = intervalTime
    }
  }

  Timer{
    id: timer
    repeat: true
    interval: 100
    onTriggered: {
      if(internal.projectOpen){
        --internal.remainingTime;
        if (internal.remainingTime < 0) {
          internal.updateShaders()
          internal.reinitRemainingTime()
        }
      }
    }
  }
  onConfigure:
  {
    configDialog.open();
  }
  ConfigurePanel
  {
    id: configDialog
    onVisibleChanged: {
      if (visible) timer.stop()
      else if (internal.projectOpen) timer.restart()
    }
    onConfigurationChanged: {
      internal.reinitRemainingTime()
      if (internal.intervalTime <= 0)
        timer.stop()
      else
        timer.restart()
    }
  }
}
