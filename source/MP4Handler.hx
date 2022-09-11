package;

import flixel.FlxBasic;
import flixel.FlxG;

#if web
import openfl.net.NetConnection;
import openfl.net.NetStream;
import openfl.events.NetStatusEvent;
import openfl.media.Video;
#else
import openfl.events.Event;
#end

#if desktop
/**
 * Play a video using cpp.
 * Use bitmap to connect to a graphic or use `MP4Sprite`.
 */
class MP4Handler extends vlc.VlcBitmap
{
	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;
	public var canSkip:Bool = true;

	var pauseMusic:Bool;

	public function new(width:Float = 320, height:Float = 240, autoScale:Bool = true)
	{
		super(width, height, autoScale);

		onVideoReady = onVLCVideoReady;
		onComplete = finishVideo;
		onError = onVLCError;

		FlxG.addChildBelowMouse(this);

		FlxG.stage.addEventListener(Event.ENTER_FRAME, update);

		FlxG.signals.focusGained.add(function()
		{
			resume();
		});
		FlxG.signals.focusLost.add(function()
		{
			pause();
		});
	}

	function update(e:Event)
	{
		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && isPlaying && canSkip)
			finishVideo();

		if (FlxG.sound.muted || FlxG.sound.volume <= 0)
			volume = 0;
		else
			volume = FlxG.sound.volume + 0.4;
	}

	#if sys
	function checkFile(fileName:String):String
	{
		var pDir = "";
		var appDir = "file:///" + Sys.getCwd() + "/";

		if (fileName.indexOf(":") == -1) // Not a path
			pDir = appDir;
		else if (fileName.indexOf("file://") == -1 || fileName.indexOf("http") == -1) // C:, D: etc? ..missing "file:///" ?
			pDir = "file:///";

		return pDir + fileName;
	}
	#end

	function onVLCVideoReady()
	{
		trace("Video loaded!");

		if (readyCallback != null)
			readyCallback();
	}

	function onVLCError()
	{
		// TODO: Catch the error
		throw "VLC caught an error!";
	}

	public function finishVideo()
	{
		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.resume();

		FlxG.stage.removeEventListener(Event.ENTER_FRAME, update);

		dispose();

		if (FlxG.game.contains(this))
		{
			FlxG.game.removeChild(this);

			if (finishCallback != null)
				finishCallback();
		}
	}

	/**
	 * Native video support for Flixel & OpenFL
	 * @param path Example: `your/video/here.mp4`
	 * @param repeat Repeat the video.
	 * @param pauseMusic Pause music until done video.
	 */
	public function playVideo(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		#if sys
		play(checkFile(path));

		this.repeat = repeat ? -1 : 0;
		#else
		throw "Doesn't support sys";
		#end
	}
}
#else

class MP4Handler extends FlxBasic
{
	public var readyCallback:Void->Void;
	public var finishCallback:Void->Void;
	public var canSkip:Bool = true;
	var netStream:NetStream;
	var pauseMusic:Bool=false;
	var player:Video;
	public function new(width:Float = 320, height:Float = 240, autoScale:Bool = true)
	{ // thanks psych <3
		super();
		player = new Video();
		player.x = 0;
		player.y = 0;
		FlxG.addChildBelowMouse(player);
		var netConnect = new NetConnection();
		netConnect.connect(null);
		netStream = new NetStream(netConnect);
		netStream.client = {
			onMetaData: function()
			{
				player.attachNetStream(netStream);
				player.width = FlxG.width;
				player.height = FlxG.height;
			}
		};
		netConnect.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent)
		{
			if (event.info.code == "NetStream.Play.Complete")
			{
				netStream.dispose();
				if (FlxG.game.contains(player))
					FlxG.game.removeChild(player);

				if (finishCallback != null)
					finishCallback();
			}
			else if (event.info.code == "NetStream.Play.Start"){
				if(readyCallback!=null)
					readyCallback();
			}
		});
		

	}

	public function playVideo(path:String, ?repeat:Bool = false, pauseMusic:Bool = false)
	{
		this.pauseMusic = pauseMusic;

		if (FlxG.sound.music != null && pauseMusic)
			FlxG.sound.music.pause();

		netStream.play(path);
	}

	override public function update(elapsed:Float)
	{
		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && canSkip){
			netStream.close();
			netStream.dispose();
			if (FlxG.game.contains(player))
				FlxG.game.removeChild(player);

			if (finishCallback != null)
				finishCallback();
		}
	}
}

#end