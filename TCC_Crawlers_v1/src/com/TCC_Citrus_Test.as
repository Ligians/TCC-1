package com
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	import citrus.core.CitrusEngine;
	
	[SWF(width=550,height=400)]
	public class TCC_Citrus_Test extends CitrusEngine
	{
		Security.allowDomain("*");
		private var gameState:DemoGameState;
		private var debugSprite:Sprite = new Sprite();
		
		[Embed(source="../../levels/level1.swf")]
		private var level1:Class;
		
		public function TCC_Citrus_Test()
		{
			sound.addSound("Hurt", "../sounds/Hurt.mp3");
			sound.addSound("Kill", "../sounds/Kill.mp3");
			
			this.console.addCommand("invert", invertAll);
			
			var mc:Level1 = new Level1();
			gameState = new DemoGameState(mc, debugSprite);
			state = gameState;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handlerLoadCompelete);
			//loader.load(new URLRequest(level1));
		}
		
		protected function handlerLoadCompelete(event:Event):void
		{
			addChild(debugSprite);
			var swfLoaded:MovieClip = event.target.loader.content as MovieClip;
			gameState = new DemoGameState(swfLoaded, debugSprite);
			state = gameState;
		}
		
		private function invertAll():void
		{
			gameState.invertAll();
		}
	}
}