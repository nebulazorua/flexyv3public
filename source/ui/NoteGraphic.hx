package ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxFrame;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.macro.Type;
import lime.utils.Assets;
import ui.Note.NoteBehaviour;
import flixel.math.FlxPoint;
import states.*;

using StringTools;

class NoteGraphic extends FNFSprite
{
	public var modifier = 'base';
	public var skin='default';
	public var graphicType='';
	public var behaviour:NoteBehaviour;
	public static var noteframeCaches:Map<String,Map<String,FlxFramesCollection>>=[];
	public static var swagWidth:Float = 160 * 0.7;
	public var quantTexture:Int = 4;
	public var noteAngles:Array<Float>=[0,0,0,0];
	public var noteOffsets:Array<Array<Null<Float>>> = [
		[0,0],
		[0,0],
		[0,0],
		[0,0]
	];

	public var scaleDefault:FlxPoint;
	public var baseAngle:Float = 0;
	public var modAngle:Float = 0;
	public var graphicDir:Int=0;

	public var skinXOffset:Float = 0;
	public var skinYOffset:Float = 0;

	public var quantToGrid:Map<Int,Int>=[
		4=>0,
		8=>1,
		12=>2,
		16=>3,
		24=>4,
		32=>5,
		48=>6,
		64=>7,
		192=>8,
	];

	public var quantToIndex:Map<Int,String>=[
		4=>"4th",
		8=>"8th",
		12=>"12th",
		16=>"16th",
		24=>"24th",
		32=>"32nd",
		48=>"48th",
		64=>"64th",
		192=>"192nd",
	];

	// TODO: redo alot of this to have shit determined when you select the noteskin

	public function new(strumTime:Float=0,?modifier:String='base',?skin:String='default', type:String='default', behaviour:NoteBehaviour)
	{
		super();
		graphicType=type;
		scaleDefault = FlxPoint.get();

		var beat = Conductor.getBeatInMeasure(strumTime);
		this.quantTexture = Note.getQuant(beat);

		this.modifier=modifier;
		this.skin=skin;
		this.behaviour=behaviour;

		var daStage:String = PlayState.curStage;
		setTextures();

		animation.play("greenScroll");
	}

	public function setTextures(){
		switch (behaviour.actsLike)
		{
			case 'pixel':
				//loadGraphic(Paths.image('pixelUI/arrows-pixels',"shared"), true, 17, 17);
				loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier, graphicType),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);
				if(behaviour.arguments.note.quant){
					var index = Reflect.field(behaviour.arguments.note,quantToIndex.get(quantTexture) );
					if(index==null){
						animation.add('greenScroll', [behaviour.arguments.note.up+4*quantToGrid.get(quantTexture)]);
						animation.add('redScroll', [behaviour.arguments.note.right+4*quantToGrid.get(quantTexture)]);
						animation.add('blueScroll', [behaviour.arguments.note.down+4*quantToGrid.get(quantTexture)]);
						animation.add('purpleScroll', [behaviour.arguments.note.left+4*quantToGrid.get(quantTexture)]);
					}else{
						var offset:Int = index.offset;
						var left:Array<Int> = [];
						var up:Array<Int> = [];
						var right:Array<Int> = [];
						var down:Array<Int> = [];

						var leftA:Array<Int> =index.left;
						var upA:Array<Int> =index.up;
						var rightA:Array<Int> =index.right;
						var downA:Array<Int> = index.down;
						for(i in leftA)left.push(i+offset);
						for(i in upA)up.push(i+offset);
						for(i in rightA)right.push(i+offset);
						for(i in downA)down.push(i+offset);
						animation.add('purpleScroll', left);
						animation.add('greenScroll', up);
						animation.add('redScroll', right);
						animation.add('blueScroll', down);

					}
				}else{
					animation.add('greenScroll', behaviour.arguments.note.up );
					animation.add('redScroll', behaviour.arguments.note.right);
					animation.add('blueScroll', behaviour.arguments.note.down);
					animation.add('purpleScroll', behaviour.arguments.note.left);
				}
				var dirs = ["left","down","up","right"];

				for(i in 0...dirs.length){
					var dir = dirs[i];
				 	var angle:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}Angle');
					if(angle!=null){
						noteAngles[i]=angle;
					}else{
						noteAngles[i]=0;
					}
					var xOffset:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}xOffset');
					if(xOffset!=null){
						noteOffsets[i][0]=xOffset;
					}else{
						noteOffsets[i][0]=0;
					}

					var yOffset:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}yOffset');
					if(yOffset!=null){
						noteOffsets[i][0]=yOffset;
					}else{
						noteOffsets[i][0]=0;
					}
				}

				setGraphicSize(Std.int(width * behaviour.scale));
				updateHitbox();
				antialiasing = behaviour.antialiasing;
				scaleDefault.set(scale.x,scale.y);
			default:
				var setSize:Bool=false;
				var args = behaviour.arguments.notes;
				var cache = noteframeCaches.get(modifier);
				if(cache==null)cache = new Map<String,FlxFramesCollection>();

				if(frames!=cache.get(graphicType) || !cache.exists(graphicType)){
					frames = !cache.exists(graphicType)?Paths.noteSkinAtlas(args.sheet, 'skins', skin, modifier, graphicType):cache.get(graphicType);
					cache.set(graphicType,frames);
					noteframeCaches.set(modifier,cache);
					setSize=true;
				}
				var quantIdx = quantToIndex.get(quantTexture);
				var field = Reflect.field(args.quants,quantIdx);
				if(args.quants!=null && field!=null ){
					var colors = [
						"purple",
						"blue",
						"green",
						"red"
					];
					var dirs = ["left","down","up","right"];

					for(i in 0...dirs.length){
						var dirData = Reflect.field(field,dirs[i]);
						var prefix = Reflect.field(dirData,"prefix");
						var longPrefix = Reflect.field(dirData,"longPrefix");
						var longEndPrefix = Reflect.field(dirData,"longEndPrefix");

						if(prefix==null)prefix=field.prefix;
						if(longPrefix==null)longPrefix=field.longPrefix;
						if(longEndPrefix==null)longEndPrefix=field.longEndPrefix;


						if(prefix==null)prefix=Reflect.field(args,dirs[i]).prefix;
						if(longPrefix==null)longPrefix=Reflect.field(args,dirs[i]).longPrefix;
						if(longEndPrefix==null)longEndPrefix=Reflect.field(args,dirs[i]).longEndPrefix;

						
						animation.addByPrefix('${colors[i]}Scroll', prefix);
						if(longPrefix!=null)
							animation.addByPrefix('${colors[i]}hold', longPrefix);
						if (longEndPrefix != null)
							animation.addByPrefix('${colors[i]}holdend', longEndPrefix);
						noteAngles[i] = dirData.angle;
						noteOffsets[i] = [dirData.xOffset==null?0:dirData.xOffset,dirData.yOffset==null?0:dirData.yOffset];
					}
				}else{
					animation.addByPrefix('greenScroll', args.up.prefix);
					animation.addByPrefix('redScroll', args.right.prefix);
					animation.addByPrefix('blueScroll', args.down.prefix);
					animation.addByPrefix('purpleScroll', args.left.prefix);
					#if web
					if(args.up.longPrefix!=null)
					#end
					animation.addByPrefix('greenhold', args.up.longPrefix);
					#if web
					if (args.right.longPrefix!=null)
						#end
					animation.addByPrefix('redhold', args.right.longPrefix);
					#if web
					if (args.down.longPrefix!=null)
						#end
					animation.addByPrefix('bluehold', args.down.longPrefix);
					#if web
					if (args.left.longPrefix!=null)
					#end
					animation.addByPrefix('purplehold', args.left.longPrefix);
					#if web
					if(args.up.longEndPrefix!=null)
					#end
					animation.addByPrefix('greenholdend', args.up.longEndPrefix);
					#if web
					if (args.right.longEndPrefix!=null)
						#end
					animation.addByPrefix('redholdend', args.right.longEndPrefix);
					#if web
					if (args.down.longEndPrefix!=null)
						#end
					animation.addByPrefix('blueholdend', args.down.longEndPrefix);
					#if web
					if (args.left.longEndPrefix!=null)
					#end
					animation.addByPrefix('purpleholdend', args.left.longEndPrefix);

					#if web
					noteAngles[0] = args.left.angle == null ? 0 : args.left.angle;
					noteAngles[1] = args.down.angle == null ? 0 : args.down.angle;
					noteAngles[2] = args.up.angle == null ? 0 : args.up.angle;
					noteAngles[3] = args.right.angle == null ? 0 : args.right.angle;
					#else
					noteAngles[0] = args.left.angle;
					noteAngles[1] = args.down.angle;
					noteAngles[2] = args.up.angle;
					noteAngles[3] = args.right.angle;
					#end

					noteOffsets[0] = [args.left.xOffset==null?0:args.left.xOffset,args.left.yOffset==null?0:args.left.yOffset];
					noteOffsets[1] = [args.down.xOffset==null?0:args.down.xOffset,args.down.yOffset==null?0:args.down.yOffset];
					noteOffsets[2] = [args.up.xOffset==null?0:args.up.xOffset,args.up.yOffset==null?0:args.up.yOffset];
					noteOffsets[3] = [args.right.xOffset==null?0:args.right.xOffset,args.right.yOffset==null?0:args.right.yOffset];
				}

				if(setSize){
					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}
				antialiasing = behaviour.antialiasing;
		}
	}

	override function update(elapsed){
		angle = baseAngle + modAngle;
		super.update(elapsed);
	}

	public function setDir(dir:Int=0,?sussy:Bool=false,?end:Bool=false){
		var colors = ["purple","blue","green","red"];
		var suffix='Scroll';
		if(sussy){
			suffix='hold';
			if(end)suffix+='end';
		};

		var quant = quantToGrid.get(quantTexture);
		if((sussy) && behaviour.actsLike=='pixel'){
			if(animation.curAnim!=null){
				if(end && !animation.curAnim.name.endsWith("end")){
					var args = behaviour.arguments.sustainEnd;

					loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier, graphicType),true,args.gridSizeX,args.gridSizeY);
					// TODO: quantsz
					if(args.quant){
						var index:Array<Int>  = Reflect.field(args,quantToIndex.get(quantTexture) );
						var gridIndex=quantToGrid.get(quantTexture);

						var offset:Int = args.offset;


						if(index!=null){
							var shit:Array<Int> = [];
							for(i in index)shit.push(i+offset);

							animation.add('purple${suffix}', shit);
							animation.add('green${suffix}', shit);
							animation.add('red${suffix}', shit);
							animation.add('blue${suffix}', shit);
						}else{
							gridIndex+=9;
							animation.add('purple${suffix}', [gridIndex]);
							animation.add('green${suffix}', [gridIndex]);
							animation.add('red${suffix}', [gridIndex]);
							animation.add('blue${suffix}', [gridIndex]);
						}
					}else{
						var offset:Int = args.offset;
						var left:Array<Int> = [];
						var up:Array<Int> = [];
						var right:Array<Int> = [];
						var down:Array<Int> = [];

						var leftA:Array<Int> =args.left;
						var upA:Array<Int> =args.up;
						var rightA:Array<Int> =args.right;
						var downA:Array<Int> = args.down;
						for(i in args.left)left.push(i+offset);
						for(i in args.up)up.push(i+offset);
						for(i in args.right)right.push(i+offset);
						for(i in args.down)down.push(i+offset);

						animation.add('purple${suffix}', left);
						animation.add('green${suffix}', up);
						animation.add('red${suffix}', right);
						animation.add('blue${suffix}', down);
					}

					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}else if(!end){
					var args = behaviour.arguments.sustain;

					loadGraphic(Paths.noteSkinImage(args.sheet, 'skins', skin, modifier, graphicType),true,args.gridSizeX,args.gridSizeY);
					// TODO: quants
					if(args.quant){
						var index = Reflect.field(args,quantToIndex.get(quantTexture) );
						var gridIndex=quantToGrid.get(quantTexture);
						var offset:Int = args.offset;
						if(index!=null){

							animation.add('purple${suffix}', index);
							animation.add('green${suffix}', index);
							animation.add('red${suffix}', index);
							animation.add('blue${suffix}', index);
						}else{
							animation.add('purple${suffix}', [gridIndex]);
							animation.add('green${suffix}', [gridIndex]);
							animation.add('red${suffix}', [gridIndex]);
							animation.add('blue${suffix}', [gridIndex]);
						}
					}else{
						animation.add('purple${suffix}', args.left);
						animation.add('green${suffix}', args.up);
						animation.add('red${suffix}', args.right);
						animation.add('blue${suffix}', args.down);
					}
					setGraphicSize(Std.int(width * behaviour.scale));
					updateHitbox();
					scaleDefault.set(scale.x,scale.y);
				}
			}
		}else if(behaviour.actsLike=='pixel' && !sussy){
			loadGraphic(Paths.noteSkinImage(behaviour.arguments.note.sheet, 'skins', skin, modifier, graphicType),true,behaviour.arguments.note.gridSizeX,behaviour.arguments.note.gridSizeY);

			if(behaviour.arguments.note.quant){
				var addition  = 4*quantToGrid.get(quantTexture);
				var index = Reflect.field(behaviour.arguments.note,quantToIndex.get(quantTexture) );
				if(index==null){
					animation.add('greenScroll', [behaviour.arguments.note.up+addition]);
					animation.add('redScroll', [behaviour.arguments.note.right+addition]);
					animation.add('blueScroll', [behaviour.arguments.note.down+addition]);
					animation.add('purpleScroll', [behaviour.arguments.note.left+addition]);
				}else{
					var offset:Int = index.offset;
					var left:Array<Int> = [];
					var up:Array<Int> = [];
					var right:Array<Int> = [];
					var down:Array<Int> = [];

					var leftA:Array<Int> =index.left;
					var upA:Array<Int> =index.up;
					var rightA:Array<Int> =index.right;
					var downA:Array<Int> = index.down;
					for(i in leftA)left.push(i+offset);
					for(i in upA)up.push(i+offset);
					for(i in rightA)right.push(i+offset);
					for(i in downA)down.push(i+offset);
					animation.add('purpleScroll', left);
					animation.add('greenScroll', up);
					animation.add('redScroll', right);
					animation.add('blueScroll', down);
				}
			}else{
				animation.add('greenScroll', behaviour.arguments.note.up );
				animation.add('redScroll', behaviour.arguments.note.right);
				animation.add('blueScroll', behaviour.arguments.note.down);
				animation.add('purpleScroll', behaviour.arguments.note.left);
			}
			var dirs = ["left","down","up","right"];

			for(i in 0...dirs.length){
				var dir = dirs[i];
				var angle:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}Angle');
				if(angle!=null){
					noteAngles[i]=angle;
				}else{
					noteAngles[i]=0;
				}

				var xOffset:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}xOffset');
				if(xOffset!=null){
					noteOffsets[i][0]=xOffset;
				}else{
					noteOffsets[i][0]=0;
				}

				var yOffset:Null<Float>= Reflect.field(behaviour.arguments.note,'${dir}yOffset');
				if(yOffset!=null){
					noteOffsets[i][0]=yOffset;
				}else{
					noteOffsets[i][0]=0;
				}
			}

			setGraphicSize(Std.int(width * behaviour.scale));
			updateHitbox();
			scaleDefault.set(scale.x,scale.y);
		}

		graphicDir=dir;

		skinXOffset = noteOffsets[dir][0];
		skinYOffset = noteOffsets[dir][1];


		if(colors[dir]!=null){
			animation.play('${colors[dir]}${suffix}',true);
			if(!sussy)
				baseAngle = noteAngles[dir];
			else
				baseAngle = 0;
		}
		updateHitbox();
	}
}
