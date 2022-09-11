package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;
import ui.*;
import flixel.math.FlxAngle;
class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var selectedCredit:Bool = false;
	var pupil:FlxSprite;
	public var currentOptions:Options;
	var logoBl:FlxSprite;
	var menuItems:FlxTypedGroup<PauseButton>;
	var gfDance:Character;
	var creditButton:FlxSprite;

	#if !switch
	var optionShit:Array<String> = ['Story Mode', 'Freeplay', 'Options', "Website"];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var camFollow:FlxObject;

	function onMouseDown(object:FlxObject){
		if (!persistentUpdate && subState != null)
			return;
		if(!selectedSomethin){
			if(object==gfDance){
				var anims = ["singUP","singLEFT","singRIGHT","singDOWN"];
				var sounds = ["GF_1","GF_2","GF_3","GF_4"];
				var anim = FlxG.random.int(0,3);
				gfDance.holdTimer=0;
				gfDance.playAnim(anims[anim]);
				FlxG.sound.play(Paths.sound(sounds[anim]));
			}else if(object==creditButton){
				var sprite:FlxSprite = cast object;
				if(sprite==creditButton){
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:PauseButton)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});	
					});
					if (OptionUtils.options.menuFlash)
					{
						FlxFlicker.flicker(creditButton, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							FlxG.switchState(new CreditState());
						});
					}
					else
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxG.switchState(new CreditState());
						});
					}
				}
			}else{
				for(obj in menuItems.members){
					var sprite:FlxSprite = cast object;
					if(obj==object || obj.members.contains(sprite)){
						accept();
						break;
					}
				}
			}
		}
	}

	function onMouseUp(object:FlxObject){

	}

	function onMouseOver(object:FlxObject){
		if(!persistentUpdate && subState!=null)return;
		if(!selectedSomethin){
			var select = selectedCredit;
			selectedCredit=false;
			for(idx in 0...menuItems.members.length){
				var sprite:FlxSprite = cast object;
				var obj:PauseButton = menuItems.members[idx];
				if(obj==object || obj.members.contains(sprite)){
					if (idx != curSelected || select){
						FlxG.sound.play(Paths.sound('scrollMenu'));
						changeItem(idx,true);
					}
				}
			}
		}
	}

	function onMouseOut(object:FlxObject){

	}

	function accept(){
		if (!persistentUpdate && subState != null)
			return;
		if (optionShit[curSelected].toLowerCase() == 'website')
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', ["https://flexybean.com/", "&"]);
			#else
			FlxG.openURL('https://flexybean.com/');
			#end
		}
		else
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			menuItems.forEach(function(spr:PauseButton)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if(OptionUtils.options.menuFlash){
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected].toLowerCase();

							switch (daChoice)
							{
								case 'story mode':
									FlxG.switchState(new StoryMenuState());
								case 'freeplay':
									FlxG.switchState(new FreeplayState());

								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}else{
						new FlxTimer().start(1, function(tmr:FlxTimer){
							var daChoice:String = optionShit[curSelected].toLowerCase();

							switch (daChoice)
							{
								case 'story mode':
									FlxG.switchState(new StoryMenuState());
								case 'freeplay':
									FlxG.switchState(new FreeplayState());

								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}
				}
			});
		}
	}

	override function create()
	{
		super.create();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		currentOptions = OptionUtils.options;

		if (FlxG.sound.music ==null || !FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/bg'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// magenta.scrollFactor.set();

		var white:FlxSprite = new FlxSprite(650, -150).loadGraphic(Paths.image("mainmenu/white"));
		white.scrollFactor.set(0, 0);
		white.antialiasing = true;
		add(white);

		pupil = new FlxSprite(790, 280).loadGraphic(Paths.image("mainmenu/pupil"));
		pupil.antialiasing = true;
		pupil.scrollFactor.set(0, 0);
		add(pupil);

		var flexy:FlxSprite = new FlxSprite(650, -150).loadGraphic(Paths.image("mainmenu/face"));
		flexy.antialiasing = true;
		flexy.scrollFactor.set(0, 0);
		add(flexy);


		var sidebar:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("mainmenu/sidebar"));
		sidebar.antialiasing = true;
		sidebar.scrollFactor.set(0, 0);
		add(sidebar);

		logoBl = new FlxSprite(-5, 460);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.4));
		logoBl.scrollFactor.set();
		logoBl.updateHitbox();
		add(logoBl);

		creditButton = new FlxSprite(50, 50).loadGraphic(Paths.image("credit"));
		creditButton.antialiasing = true;
		creditButton.scrollFactor.set();
		add(creditButton);
		FlxMouseEventManager.add(creditButton, onMouseDown, onMouseUp, null, onMouseOut);

		menuItems = new FlxTypedGroup<PauseButton>();
		add(menuItems);

		/*
		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;

			FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}
		*/
		for (i in 0...optionShit.length)
		{
			var text = optionShit[i];
			var songText:PauseButton = new PauseButton(50, (i * 100) + (FlxG.height * 0.3), text);
			songText.targetY = i;
			songText.scrollFactor.set();
			songText.screenCenter(XY);
			var input:Float = FlxAngle.asRadians((i + 2) * 45);

			songText.x = (((FlxG.width/2) - 300) - FlxMath.fastSin(input) * 150) - (75 * i) + ((75 * CoolUtil.clamp(i-1, 0, 1)));
			switch(i){
				case 0 | 1: // nothing
				case 2:
					songText.x += 15;
				case 3:
					songText.x += 150;
				default: // shouldnt ever be done probably
			}
			// god there is probably a better way to do this all but idc

			songText.y = 50 + (i * 200); //((i * 100) + (FlxG.height * 0.3) - songText.bg.height/2) - 20;
			songText.xScale = 1.25;
			songText.yScale = 1.25;
			songText.ID = i;
			menuItems.add(songText);

			FlxMouseEventManager.add(songText,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}



		FlxG.camera.follow(camFollow, null, Main.adjustFPS(0.06));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 1, 0, "v" + Application.current.meta.get('version') + " - Andromeda Engine PR1", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

	}

	var selectedSomethin:Bool = false;
	override function beatHit(){
		super.beatHit();
		if(gfDance!=null){
			if (!gfDance.animation.curAnim.name.startsWith("sing") && gfDance.animation.curAnim.name!="cheer")
				gfDance.dance();
		}
		if(logoBl!=null)
			logoBl.animation.play("bump");

	}

	var angleShit:Float = 0;
	override function update(elapsed:Float)
	{
		if(FlxG.mouse.overlaps(creditButton) && !selectedCredit){
			selectedCredit=true;
			FlxG.sound.play(Paths.sound('scrollMenu'));
			menuItems.forEach(function(spr:PauseButton)
			{
				spr.targetY = -1;
				spr.updateHitbox();
			});
		}
		creditButton.scale.x = FlxMath.lerp(creditButton.scale.x, selectedCredit ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
		creditButton.scale.y = FlxMath.lerp(creditButton.scale.y, selectedCredit ? 1.1 : 1, 0.15 * (elapsed / (1 / 60)));
		
		angleShit += elapsed / 4;
		if(logoBl!=null)
			logoBl.angle = FlxMath.fastCos(angleShit) * 15;
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;


		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.mouse.visible=true;

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				selectedCredit=false;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				selectedCredit = false;
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT){
				if(selectedCredit)
					onMouseDown(creditButton);
				else
					accept();
			}

		}

		var idx:Int = 0;

		var lerpVal:Float = 0.4 * (elapsed / (1/120) );
		for (item in menuItems.members)
		{
			idx++;

			if (item.targetY == 0)
			{
				//item.x = FlxMath.lerp(item.x, 65, lerpVal);
				item.xScale = FlxMath.lerp(item.xScale, 1.4, lerpVal);
				item.yScale = FlxMath.lerp(item.yScale, 1.4, lerpVal);
			}else{
				//item.x = FlxMath.lerp(item.x, 50, lerpVal);
				item.xScale = FlxMath.lerp(item.xScale, 1.25, lerpVal);
				item.yScale = FlxMath.lerp(item.yScale, 1.25, lerpVal);
			}
		}

		var mix = FlxMath.lerp(280, menuItems.members[curSelected].y, .15);
		pupil.y = FlxMath.lerp(pupil.y, mix, 0.15 * (elapsed / (1/120) ));

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/

	}

	function changeItem(huh:Int = 0,force:Bool=false)
	{
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		var bullShit:Int = 0;
		menuItems.forEach(function(spr:PauseButton)
		{
			spr.targetY = bullShit - curSelected;
			if (selectedCredit)spr.targetY = -1;
			bullShit++;


			spr.updateHitbox();
		});
	}
}
