package states;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import ui.Alphabet;
import flixel.FlxSprite;

typedef CreditInfo = {
    var imageName:String;
    var name:String;
    var desc:String;
    @:optional var quote:String;
    @:optional var social:String;
}
class CreditState extends MusicBeatState {
	function onMouseDown(object:FlxObject)
	{
		if (!persistentUpdate)
			return;
		var spr:FlxSprite = cast object;
		if (grid.exists(spr))
		{
			var data = grid.get(spr);
            if(data.social!=null){
			#if linux
			Sys.command('/usr/bin/xdg-open', [data.social, "&"]);
			#else
			FlxG.openURL(data.social);
			#end
            }
        }
	}

	function onMouseUp(object:FlxObject)
	{
	}

	function onMouseOver(object:FlxObject)
	{
		if (!persistentUpdate)return;
		var spr:FlxSprite = cast object;
		if (grid.exists(spr))
		{
			var data = grid.get(spr);
			nameText.text = data.name;
			descText.text = data.desc;
			quoteText.visible=data.quote!=null;
			if (data.quote != null)
				quoteText.text = '"${data.quote}"';

			for (k in portraits.keys())
			{
				var v = portraits.get(k);
				v.visible = k == data.name;
			}
			var idx = credits.indexOf(data);
			if (selected != idx)
				FlxG.sound.play(Paths.sound('scrollMenu'));
			selected = idx;
		}

	}

	function onMouseOut(object:FlxObject)
	{
	}


    var credits:Array<CreditInfo> = [
        {
            imageName: "ravvy",
            name: "Ravvy Tavvy",
            quote: "You can call me Ravvy Tavvy gettin' all up on flexy like he's the krabby patty",
            desc: "Lead director, created all the characters, drew every asset that isn't otherwise mentioned",
			social: "https://www.instagram.com/ravvy_tavvy/"
        },
        {
            imageName: "echolocated",
            name: "Echolocated",
            quote: "I spent 60 hours making them sing the lyrics to Globetrotter",
			desc: "Lead musician, co-director, made lighting look pretty, helped edit cutscenes and made Stepbro's sprites",
			social: "https://www.youtube.com/c/EcholocatedOfficial"
        },
        {
            imageName: "nebula",
            name: "Nebula the Zorua",
            quote: "SnowTheFox.... :drool:",
            desc: "Lead and only programmer for Flexy 1.0, 2.0 and 3.0\n(I mean I guess echo did the odd thing here and there)"
        },
        {
            imageName: "matasaki",
            name: "Matasaki",
            quote: "Most people know me as Mat, just an amateur musician and artist enjoying the good times with Flexy's friends",
			desc: "Composed menu theme, pause theme and credits theme",
			social: "https://twitter.com/Matasaki_Dude"
        },
        {
            imageName: "wilde",
            name: "Wilde",
            quote: "No cap would totally bang the up arrow from FNF",
			desc: "Charted most if not all songs",
			social: "https://twitter.com/0WildeRaze"
        },
        {
            imageName: "dpz",
            name: "DPZ",
			desc: "Composed instrumental for Snowflek",
			social: "https://twitter.com/dpzmusic"
        },
        {
            imageName: "lse",
            name: "LongestSoloEver",
            quote: "ableton rad, FL bad",
			desc: "Composed Malvado",
			social: "https://twitter.com/longestsoloever"
        },
        {
            imageName: "pastelulu",
            name: "Pastelulu",
            quote: "I want him to rail me",
			desc: "Designed GF, made Flexy hot",
			social: "https://twitter.com/pasteluluu"
        },
		{
			imageName: "bepixel",
			name: "Bepixel",
			desc: "Animated most if not all of the sprites",
			quote: "I hate twitter",
			social: "https://twitter.com/BepixelOfficial"
		},
        {
			imageName: "thebrightstarr",
            name: "TheBrightStar",
            quote: "Connor made me sound good lol I am flexy heehee",
			desc: "Voiced Flexy, moral support through and through",
			social: "https://twitter.com/The_BrightStarr"
        },
        {
            imageName: "nicky",
            name: "Nickname Animates",
            quote: "lol u copied fnf mod",
			desc: "Made the new BF",
			social: "https://twitter.com/NickAnimates_"
		},
		{
			imageName: "anon",
			name: "Anon",
			desc: "Charted unused version of Stepped Up Gran Venta"
		},
        {
            imageName: "mrcup",
            name: "Mr. Cup",
            desc: "Voiced Merchant",
			quote: "I was the conveniently placed peruvian friend. So you can tell I'm ESL"
        },
		{
			imageName: "sticky",
            name: "StickyBM",
			desc: "Voiced Stepbro",
			quote: "It's burpin' time",
			social: "https://twitter.com/StickyBM"
		},
		{
			imageName: "esther",
			name: "Esther",
			quote: "I'm literaly cracked",
			desc: "Main Playtester",
			social: "https://twitter.com/Esther_system"
		},
		{
			imageName: "flippy",
			name: "Flippy",
			desc: "Playtested Flexy 2.0",
			quote: "Quite literally flipping out rn",
			social: "https://www.youtube.com/c/FlippyFNF"
        }
    ];

    var portraits:Map<String, FlxSprite> = [];
    var grid:Map<FlxSprite, CreditInfo> = [];

    var selected:Int = 0;

    var nameText:FlxText;
    var descText:FlxText;
    var quoteText:FlxText;

    override function create() {
		super.create();
		if (FlxG.sound.music == null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		
		persistentUpdate = persistentDraw = true;
        var bg = new FlxSprite().loadGraphic(Paths.image("credit/creditbg"));
        add(bg);
		FlxG.mouse.visible = true;

        var yOffset = 0;
        for(idx in 0...credits.length){
            var credit = credits[idx];
			var bigPort = new FlxSprite().loadGraphic(Paths.image('credit/portraits/${credit.imageName}'));
			bigPort.antialiasing = true;
            bigPort.x = 796;
            bigPort.y = 89;

			var smallPort = new FlxSprite(75 + (idx%4 * 150), 75 + (yOffset * 150) ).loadGraphic(Paths.image('credit/portraits/${credit.imageName}'));
			smallPort.antialiasing=true;
            smallPort.setGraphicSize(Std.int(smallPort.width * 0.33));
			smallPort.updateHitbox();
			if (idx % 4 == 3)
				yOffset++;
			
            bigPort.visible = idx==0;

            add(smallPort);
            add(bigPort);

			portraits.set(credit.name, bigPort);
			grid.set(smallPort, credit);

			FlxMouseEventManager.add(smallPort, onMouseDown, onMouseUp, onMouseOver, onMouseOut, false, true, false);
        }
		nameText = new FlxText(796, 60, 403, credits[0].name, 30);
		nameText.setFormat(Paths.font("Summer Square.otf"), 30, FlxColor.WHITE, CENTER);
		add(nameText);

		descText = new FlxText(796, 500, 403, credits[0].desc, 24);
		descText.setFormat(Paths.font("Summer Square.otf"), 24, FlxColor.WHITE, CENTER);
		add(descText);

		quoteText = new FlxText(796, 600, 403, '"${credits[0].quote}"', 24);
		quoteText.setFormat(Paths.font("Summer Square.otf"), 24, FlxColor.WHITE, CENTER);
		add(quoteText);
    }

    override function update(elapsed:Float){
        super.update(elapsed);
		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
            return;
		}
		for (sprite in grid.keys()){
            var data = grid.get(sprite);
            var index = credits.indexOf(data);
			sprite.scale.x = FlxMath.lerp(sprite.scale.x, index == selected ? 0.4 : 0.33, 0.15 * (elapsed / (1 / 60)));
			sprite.scale.y = FlxMath.lerp(sprite.scale.y, index == selected ? 0.4 : 0.33, 0.15 * (elapsed / (1 / 60)));
        }
    }
}