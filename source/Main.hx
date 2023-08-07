package;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import ui.FPSDisplay as FPS;
import ui.Volume;
#if windows
#if !neko
import Discord.DiscordClient;
#end
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import lime.app.Application;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	var fpsCounter:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FNFData.firstStart(); // set default settings (if first start)
		FNFData.loadSave(); // load your keybinds and etc..
		FlxG.drawFramerate = FlxG.save.data.fpslimit;
		FlxG.updateFramerate = FlxG.save.data.fpslimit;

		#if windows
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		fpsCounter = new FPS();
        addChild(fpsCounter);

		var volume:Volume = new Volume();
		addChild(volume);

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
	}

	function onWindowFocusOut()
	{
		FlxTween.tween(FlxG.sound, {volume: FlxG.save.data.volume / 50}, 0.65);
	}

	function onWindowFocusIn()
	{
		FlxTween.tween(FlxG.sound, {volume: FlxG.save.data.volume}, 0.65);
	}

	#if windows
	function onCrash(e:UncaughtErrorEvent):Void
	{
		DiscordClient.shutdown();

		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		errMsg += 'Simple Engine crashed!%%';

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")%";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "%Uncaught Error: " + e.error + "%";
		errMsg += "%Engine version: " + FNFData.version;

		errMsg += '%%Report this to my discord: ycken';

		if (sys.FileSystem.exists(Sys.getCwd() + "\\CrashHandler.exe")){
			var dir:String = Sys.getCwd();
			Sys.command(dir + 'CrashHandler.exe', [errMsg]);
		}
		if (!sys.FileSystem.exists(Sys.getCwd() + "\\CrashHandler.exe"))
		{
			Sys.exit(1);
		}
	}
	#end
}
