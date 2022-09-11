package;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if desktop
import LuaClass;
#end
import ui.*;
import flash.display.BitmapData;
import Sys;
import flixel.util.FlxDestroyUtil;
import openfl.media.Sound;
import flixel.FlxBasic;
import openfl.system.System;
import flixel.graphics.FlxGraphic;

class Cache {
  public static var persistentImages:Array<FlxGraphic> = [];
  public static var offsetData = new Map<String,String>();
  public static var animData = new Map<String,String>();
  public static var charFrames = new Map<String,FlxFramesCollection>();
  public static var charXmlData = new Map<String,String>();
  public static var xmlData = new Map<String,String>();
  public static var textCache = new Map<String,String>();
  public static var pathCache = new Map<String,String>();
  public static var soundCache = new Map<String,Sound>();

  public static function wipe(){ // a COMPLETE cache clear
    pathCache.clear();
    xmlData.clear();
    soundCache.clear();
    clear();
    clearImages();

    trace("WIPED CACHE!");
  }

  public static function clear(){ // clears most things that are cached
    offsetData.clear();
    animData.clear();
    charFrames.clear();
    textCache.clear();
    charXmlData.clear();
		#if desktop
    LuaStorage.objectProperties.clear();
    LuaStorage.objects.clear();
    LuaStorage.notes=[];
    LuaStorage.noteIDs.clear();
    LuaStorage.noteMap.clear();
    #end
    Note.behaviours.clear();
    NoteGraphic.noteframeCaches.clear();
    NoteSplash.splashCache.clear();
    trace("CLEARED CACHE!");
  }

  public static function clearImages(force:Bool=false){
    // CREDIT TO HAYA AND SHUBS
    // TRY OUT FOREVER ENGINE!
    // NO, LIKE, SERIOUSLY.
    // https://github.com/Yoshubs/Forever-Engine-Legacy
    if(!EngineData.options.cacheUsedImages){
      var l:Int = 0;
      @:privateAccess
      for (key in FlxG.bitmap._cache.keys())
      {
        var obj = FlxG.bitmap._cache.get(key);
        if (obj != null && (!persistentImages.contains(obj) || force))
        {
          Assets.cache.removeBitmapData(key);
          FlxG.bitmap._cache.remove(key);
          obj.destroy();
          l++;
        }
      }
      trace('destroyed ${l}');
      System.gc();
    }
  }

  public static function getXML(path:String):Null<String>{ // gets an XML file and caches it if it hasnt been already

		if (xmlData.exists(path))
			return xmlData.get(path);

		if (Assets.exists(path, TEXT) && !xmlData.exists(path))
		{
			xmlData.set(path, Assets.getText(path));
		}#if sys
    else if(FileSystem.exists(path) && !xmlData.exists(path)){
      xmlData.set(path,File.getContent(path));
    }
    #end

		return xmlData.get(path);
  }

  public static function getText(path:String):Null<String>{ // gets a text file and caches it if it hasnt been already
		if (textCache.exists(path))
		{
			return textCache.get(path);
		}
    
    if (Assets.exists(path, TEXT) && !textCache.exists(path))
		{
			textCache.set(path, Assets.getText(path));
		}
		#if sys
		else if (FileSystem.exists(path) && !textCache.exists(path))
		{
			textCache.set(path, File.getContent(path));
		}
		#end

		return textCache.get(path);
  }

}
