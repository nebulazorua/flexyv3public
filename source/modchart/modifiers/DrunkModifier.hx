package modchart.modifiers;
import ui.*;
import modchart.*;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.FlxG;
import math.*;

class DrunkModifier extends Modifier {
	override function movesShit()
	{
		return true;
	}

  override function getPath(visualDiff:Float, pos:Vector3, data:Int, player:Int, timeDiff:Float){
    var drunkPerc = getPercent(player);
    var tipsyPerc = getSubmodPercent("tipsy",player);
    var bumpyPerc = getSubmodPercent("bumpy",player);
    var timeFactor = getModPercent("waveTimeFactor", player);

    var time = (Conductor.songPosition/1000) * timeFactor;
    if(tipsyPerc!=0){
      var speed = getSubmodPercent("tipsySpeed",player);
      var offset = getSubmodPercent("tipsyOffset",player);
      pos.y += tipsyPerc * (FlxMath.fastCos((time*((speed*1.2)+1.2) + data*((offset * 1.8)+1.8))) * Note.swagWidth*.4);
    }

    if(drunkPerc!=0){
      var speed = getSubmodPercent("drunkSpeed",player);
      var period = getSubmodPercent("drunkPeriod",player);
      var offset = getSubmodPercent("drunkOffset",player);

      var angle = time * (1+speed) + data*( (offset*0.2) + 0.2)
		    + visualDiff * ( (period*10) + 10) / FlxG.height;
      pos.x += drunkPerc * (FlxMath.fastCos(angle) * Note.swagWidth * 0.5);
    }

    if(bumpyPerc!=0){
      /*
      		fZPos += fEffects[PlayerOptions::EFFECT_BUMPY] * 40*RageFastSin(
			CalculateBumpyAngle(fYOffset,
			fEffects[PlayerOptions::EFFECT_BUMPY_OFFSET],
			fEffects[PlayerOptions::EFFECT_BUMPY_PERIOD]) );
      */
			var speed = getSubmodPercent("bumpySpeed", player);
			var period = getSubmodPercent("bumpyPeriod", player);
			var offset = getSubmodPercent("bumpyOffset", player);
			var angle = (visualDiff + (100.0 * offset)) / ((period * 16.0) + 16.0);
      //pos.z += (bumpyPerc * (.3 * FlxMath.fastSin((visualDiff/24)*bumpySpeed)));
			pos.z += (bumpyPerc * 40 * FlxMath.fastSin(angle))/125;
    }


    return pos;
  }

  override function getSubmods(){
    return [
      "tipsy",
      "bumpy",
      "drunkSpeed",
      "drunkOffset",
      "drunkPeriod",
      "tipsySpeed",
      "tipsyOffset",
      "bumpySpeed",
      "bumpyOffset",
      "bumpyPeriod"
    ];
  }

}
