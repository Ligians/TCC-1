package com.hero
{
	import com.Fog;
	import com.ImageConstants;
	import com.levels.ILevel;
	import com.objects.Rock;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.Contacts.b2Contact;
	
	import citrus.input.controllers.Keyboard;
	import citrus.math.MathVector;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2DUtils;
	import citrus.physics.box2d.IBox2DPhysicsObject;
	import citrus.view.ACitrusCamera;
	import citrus.view.spriteview.SpriteArt;
	
	public class MyHero extends Hero
	{
		private var initialPos:Point;
		private var isInverted:Boolean;
		private var radToDeg:Number = 180/Math.PI;
		private var angleOfShoot:Number;
		private var _sprite:Sprite = new Sprite();
		public var rock:Rock;
		public var rock1:RockAsset;
		private var _worldScale:Number;
		private var _world:b2World;
		private var withRock:Boolean = false;
		private var iLevel:ILevel;
		private var fog:Fog;
		private var isWithTorch:Boolean = false;
		private var _camPos:Point;
		private var insanity:int = 0;
		private var insanityDangerous:int = 50;
		private var insanityLimit:int = 100;
		private var insanityDebug:Boolean;
		private var insanityTime:int = 5;
		private var FRAME_RATE:int;
		private var ticks:int;
		private var seconds:int;
		private var minutes:int;
		private var isInsane:Boolean = false;
		private var cameraUsed:Boolean = false;
		private var usingFlashlight:Boolean = false;
		
		private var insanityBarBackgorund:Sprite;
		private var insanityBar:Sprite;
		private var dirX:Number;
		private var dirY:Number;
		private var arrayOfRocks:Vector.<Rock>;
		private var shadow:Shadow;
		private var isWithFlashlight:Boolean;
		private var flashlightEnergy:int;
		private var maxFlashlightEnergy:int = 100;
		private var minFlashlightEnergy:int = 10;
		private var _cam:ACitrusCamera;
		
		public function MyHero(name:String, params:Object=null)
		{
			super(name, params);
			this.view = ImageConstants.HERO;
		}
		
		public function init():void
		{
			FRAME_RATE = _ce.stage.frameRate;
			insanityTime = insanityTime*FRAME_RATE;
			setDebugInsanity(true);
			//_camPos = iLevel.getCamPos();
			fog = new Fog(this, _cam, 0, 0, _ce.stage.stageWidth, _ce.stage.stageHeight);
			fog.setFrameRate(FRAME_RATE);
			fog.init();
			_ce.addChild(fog);
			drawInsanityBar();
			arrayOfRocks = new Vector.<Rock>;
			
			setupHeroAction();
			createShadow();
		}
		
		private function createShadow():void
		{
			shadow = new Shadow();
			//shadow.setAsset(hero.getViewAsMovieClip());
			shadow.setHero(this);
			//shadow.x = hero.x - hero.width/2;
			//shadow.y = hero.y - hero.height/2;
			_ce.addChild(shadow);
			shadow.addEventListener(MouseEvent.CLICK, onClickShadow);
		}
		
		protected function onClickShadow(event:MouseEvent):void
		{
			invertWorld();
		}
		
		private function setupHeroAction():void
		{
			
			var keyboard:Keyboard = _ce.input.keyboard as Keyboard;
			keyboard.addKeyAction("fly", Keyboard.F, inputChannel);
			keyboard.addKeyAction(HeroActions.LEFT, Keyboard.A, inputChannel);
			keyboard.addKeyAction(HeroActions.RIGHT, Keyboard.D, inputChannel);
			keyboard.addKeyAction(HeroActions.INVERT, Keyboard.Z, inputChannel);
			keyboard.addKeyAction(HeroActions.CAMERA, Keyboard.SHIFT, inputChannel);
			keyboard.addKeyAction(HeroActions.FLASHLIGHT, Keyboard.X, inputChannel);
		}
		
		private function drawInsanityBar():void
		{
			insanityBarBackgorund = new Sprite();
			insanityBarBackgorund.graphics.beginFill(0x888888, .6);
			insanityBarBackgorund.graphics.drawRect(10, 10, 210, 40);
			_ce.addChild(insanityBarBackgorund);
			
			insanityBar = new Sprite();
			insanityBar.graphics.beginFill(0x0000FF, .6);
			insanityBar.graphics.drawRect(15, 15, 200, 30);
			_ce.addChild(insanityBar);
			insanityBar.scaleX = 0;
			
			if(!insanityDebug){
				insanityBarBackgorund.visible = false;
				insanityBar.visible = false;
			}
		}
		
		public function shootRock():void
		{
			trace("vou atirar");
			trace("_sprite.mouseY " + _sprite.mouseY);
			trace("this.y " + this.y);
			var myPosX:Number = this.x - _camPos.x;
			var myPosY:Number = this.y - _camPos.y;
			trace("myPosY " + myPosY);
			
			angleOfShoot = Math.atan2(_sprite.mouseY - myPosY, _sprite.mouseX - myPosX);//the angle that it must move
			rock = new Rock("rock", _world, _worldScale, this.x, this.y, angleOfShoot, {width:10, height:10, radius:5, view: "../lib/pedra2_resize.png"});
			_ce.state.add(rock);
			//rock.calcPosition();
			rock1 = new RockAsset();
			//_ce.addChild(rock);
			
			
			rock.x = this.x + (50 * Math.cos(angleOfShoot));
			rock.y = this.y + (50 * Math.sin(angleOfShoot));
			//rock.dirX = new Number();
			rock.dirX = Math.cos(angleOfShoot) * 10;
			//rock.dirY = new Number();
			rock.dirY = Math.sin(angleOfShoot) * 10;
			arrayOfRocks.push(rock);
			
			dirX = Math.cos(angleOfShoot) * 10;
			dirY = Math.sin(angleOfShoot) * 10;
			
			setWithRock(false);
			//TODO arrumar rock tirar do state
			//_state.rock.x = 518;
			//_state.rock.y = 671;
			
			/*ySpeed=Math.sin(angle) * maxSpeed;//calculate how much it should move the enemy vertically
			xSpeed=Math.cos(angle) * maxSpeed;//calculate how much it should move the enemy horizontally
			//move the bullet towards the enemy
			this.x+= xSpeed;
			this.y+= ySpeed;*/
		}
		
		public function reset():void
		{
			//(_ce.state as DemoGameState).delayer.push(resetRotation);
			
			setTimeout(resetRotation, 0);
			
			if(isInverted){
				this.cancelInverted();
			}
			this.x = initialPos.x;
			this.y = initialPos.y;
			this.rotation = 90;
			insanity = 0;
			withRock = false;
			isWithTorch = false;
			isWithFlashlight = false;
			usingFlashlight = false;
			isInsane = false;
			cameraUsed = false;
			fog.reset();
			var normalColor:ColorTransform = new ColorTransform();
			normalColor.color = 0x0000FF;
			insanityBar.transform.colorTransform = normalColor;
		}
		
		private function resetRotation():void
		{
			this.rotation = 0;
		}
		
		override public function handleBeginContact(contact:b2Contact):void {
			var collider:IBox2DPhysicsObject = Box2DUtils.CollisionGetOther(this, contact);
			
			if (_enemyClass && collider is _enemyClass)
			{
				if (_body.GetLinearVelocity().y < killVelocity && !_hurt)
				{
					hurt();
					
					//fling the hero
					var hurtVelocity:b2Vec2 = _body.GetLinearVelocity();
					hurtVelocity.y = -hurtVelocityY;
					hurtVelocity.x = hurtVelocityX;
					if (collider.x > x)
						hurtVelocity.x = -hurtVelocityX;
					_body.SetLinearVelocity(hurtVelocity);
				}
				else
				{
					_springOffEnemy = collider.y - height;
					onGiveDamage.dispatch();
				}
			}
			
			//Collision angle if we don't touch a Sensor.
			if (contact.GetManifold().m_localPoint && !(collider is Sensor)) //The normal property doesn't come through all the time. I think doesn't come through against sensors.
			{				
				var collisionAngle:Number = (((new MathVector(contact.normal.x, contact.normal.y).angle) * 180 / Math.PI) + 360) % 360;// 0º <-> 360º
				
				if ((collisionAngle > 45 && collisionAngle < 135))
				{
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
				if((collisionAngle > 225 && collisionAngle < 315)){
					_groundContacts.push(collider.body.GetFixtureList());
					_onGround = true;
					updateCombinedGroundAngle();
				}
			}
		}
		
		override public function update(timeDelta:Number):void
		{
			super.update(timeDelta);
			
			ticks = iLevel.getTicks();
			seconds = iLevel.getSeconds();
			minutes = iLevel.getMinutes();
			
			updateInsanity();
			debugInsanity();
			updateRocksPosition();
			
			updateShadowPosition();
			
			
			// we get a reference to the actual velocity vector
			var velocity:b2Vec2 = _body.GetLinearVelocity();
			
			if (controlsEnabled)
			{
				var moveKeyPressed:Boolean = false;
				
				_ducking = (_ce.input.isDoing("duck", inputChannel) && _onGround && canDuck);
				
				if(_ce.input.justDid(HeroActions.CAMERA, inputChannel) && !this.cameraUsed)
				{
					useCamera();
				}
				
				if(_ce.input.justDid(HeroActions.FLASHLIGHT, inputChannel) && !this.cameraUsed)
				{
					useFlashlight();
				}
				
				if(_ce.input.justDid(HeroActions.INVERT, inputChannel))
				{
					invertWorld();
				}
				
				if(_ce.input.justDid("fly", inputChannel))
				{
					//insert "start flying" code here
				}
				
				if(_ce.input.isDoing("fly", inputChannel))
				{
					//if you are using a controller such as a joystick and want to give more control to your player, you can use the new getActionValue method
					var flying_intensity:Number = _ce.input.getActionValue("fly", inputChannel);
					//and apply it.
					velocity.y = - flying_intensity * 150; //this is just an example application, it might not be as accurate as you'd want it to.
					
					//insert other "flying" code here
				}
				
				if (_ce.input.isDoing(HeroActions.RIGHT, inputChannel) && !_ducking)
				{
					velocity.Add(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				if (_ce.input.isDoing(HeroActions.LEFT, inputChannel) && !_ducking)
				{
					velocity.Subtract(getSlopeBasedMoveAngle());
					moveKeyPressed = true;
				}
				
				//If player just started moving the hero this tick.
				if (moveKeyPressed && !_playerMovingHero)
				{
					_playerMovingHero = true;
					_fixture.SetFriction(0); //Take away friction so he can accelerate.
				}
					//Player just stopped moving the hero this tick.
				else if (!moveKeyPressed && _playerMovingHero)
				{
					_playerMovingHero = false;
					_fixture.SetFriction(_friction); //Add friction so that he stops running
				}
				
				if (_onGround && _ce.input.justDid(HeroActions.JUMP, inputChannel) && !_ducking)
				{
					if(isInverted){
						velocity.y = jumpHeight;
					}else{
						velocity.y = -jumpHeight;
					}
					onJump.dispatch();
				}
				
				if (_ce.input.isDoing(HeroActions.JUMP, inputChannel) && !_onGround && velocity.y < 0)
				{
					if(isInverted){
						velocity.y += jumpAcceleration;
					}else{
						velocity.y -= jumpAcceleration;
					}
				}
				
				if (_springOffEnemy != -1)
				{
					if (_ce.input.isDoing(HeroActions.JUMP, inputChannel))
						velocity.y = -enemySpringJumpHeight;
					else
						velocity.y = -enemySpringHeight;
					_springOffEnemy = -1;
				}
				
				//Cap velocities
				if (velocity.x > (maxVelocity))
					velocity.x = maxVelocity;
				else if (velocity.x < (-maxVelocity))
					velocity.x = -maxVelocity;
			}
			
			updateAnimation();
		}
		
		private function updateShadowPosition():void
		{
			//shadow.x = this.x - this.width/2 - _cam.transformMatrix.transformPoint(new Point(0,0)).x;
			shadow.x = this.x - this.width/2 + _cam.transformMatrix.transformPoint(new Point(0,0)).x;
			shadow.y = this.y - this.height/2 + _cam.transformMatrix.transformPoint(new Point(0,0)).y;
			
			//shadow.x = _ce.localToGlobal(new Point(this.x - this.width/2 - this.getCamPos().x, this.y - this.height/2 - this.getCamPos().y)).x;
			//shadow.y = _ce.localToGlobal(new Point(this.x - this.width/2 - this.getCamPos().x, this.y - this.height/2 - this.getCamPos().y)).y;
		}
		
		private function updateRocksPosition():void
		{
			for (var i:int = 0; i < arrayOfRocks.length; i++) 
			{
				if(arrayOfRocks[i]){
					arrayOfRocks[i].getBody().SetLinearVelocity(new b2Vec2(arrayOfRocks[i].dirX,arrayOfRocks[i].dirY));
					/*arrayOfRocks[i].x += arrayOfRocks[i].dirX;
					arrayOfRocks[i].y += arrayOfRocks[i].dirY;*/
				}
			}
		}
		
		private function debugInsanity():void
		{
			if(insanityDebug){
				
			}
		}
		
		private function updateInsanity():void
		{
			if((ticks % insanityTime * FRAME_RATE) == 0){
				if(!isInverted){
					insanity+=2;
				}else{
					insanity-=2;
				}
				insanityBar.scaleX = insanity / insanityLimit;
				//trace(shadow.scaleX);
				shadow.scaleX = shadow.scaleY = (insanity / insanityLimit) + 1;
			}
			if(insanity >= insanityDangerous && insanity <= insanityLimit){
				isInsane = true;
				var insaneColor:ColorTransform = new ColorTransform();
				insaneColor.color = 0xFF0000;
				insanityBar.transform.colorTransform = insaneColor;
			}else if(insanity > insanityLimit){
				trace("morreu de loucura");
				this.reset();
			}else{
				if(isInsane){
					var normalColor:ColorTransform = new ColorTransform();
					normalColor.color = 0x0000FF;
					insanityBar.transform.colorTransform = normalColor;
					this.cancelInverted();
					isInsane = false;
				}
			}
		}
		
		public function getViewAsMovieClip():MovieClip
		{
			var art:SpriteArt = _ce.state.view.getArt(this) as SpriteArt;
			
			if(art != null && art.content != null){
				return (art.content as MovieClip);
			}
			return null;
		}
		
		private function cancelInverted():void
		{
			insanity = 0;
			//TODO arrumar o invert e tirar do state
			invertWorld();
			isInsane = false;
			//iLevel.invertAll();
		}
		
		private function invertWorld():void
		{
			if(isInsane){
				trace("vou inverter");
				if(this.rotation == 0){
					this.rotation = 180;
					isInverted = true;
				}else{
					this.rotation = 0;
					isInverted = false;
				}
				iLevel.invertAll();
			}
		}
		
		public function setInverted(value:Boolean):void
		{
			isInverted = value;
			fog.setInverted(isInverted);
		}
		
		public function setWorldScale(value:Number):void
		{
			_worldScale = value;
		}
		
		public function setWorld(value:b2World):void
		{
			_world = value;
		}
		
		public function setWithRock(value:Boolean):void
		{
			withRock = value;
		}
		
		public function getWithRock():Boolean
		{
			return withRock;
		}
		
		public function setState(value:ILevel):void
		{
			iLevel = value;
		}
		
		public function useCamera():void
		{
			insanity += 10;
			cameraUsed = true;
			fog.useCamera();
		}
		
		public function useFlashlight():void
		{
			if(this.isWithFlashlight && this.flashlightEnergy > this.minFlashlightEnergy){
				usingFlashlight = true;
				fog.useFlashlight();
			}else if(this.isWithFlashlight && this.usingFlashlight){
				usingFlashlight = false;
				fog.useFlashlight();
			}
		}
		
		public function setInitialPos(value:Point):void
		{
			initialPos = value;
		}
		
		public function setWithTorch(value:Boolean):void
		{
			isWithTorch = value;
			fog.setWithTorch(value);
		}
		
		public function setWithFlashlight(value:Boolean):void
		{
			this.flashlightEnergy = maxFlashlightEnergy;
			isWithFlashlight = value;
		}
		
		private function setDebugInsanity(value:Boolean):void
		{
			insanityDebug = value;
		}
		
		public function getIsInsane():Boolean
		{
			return isInsane;
		}
		
		public function setCameraUsed(value:Boolean):void
		{
			cameraUsed = value;
		}
		
		public function getCameraUsed():Boolean
		{
			return cameraUsed;
		}

		public function getCamPos():Point
		{
			return _camPos;
		}

		public function setCamPos(value:Point):void
		{
			_camPos = value;
		}
		
		public function getInsanity():int
		{
			return insanity;
		}

		public function getFlashlightEnergy():int
		{
			return flashlightEnergy;
		}

		public function setFlashlightEnergy(value:int):void
		{
			flashlightEnergy = value;
		}

		public function getMinFlashlightEnergy():int
		{
			return minFlashlightEnergy;
		}
		
		public function addFlashlightEnergy(value:int):void
		{
			flashlightEnergy += value;
		}
		
		public function substractFlashlightEnergy(value:int):void
		{
			flashlightEnergy -= value;
		}

		public function setMinFlashlightEnergy(value:int):void
		{
			minFlashlightEnergy = value;
		}

		public function getMaxFlashlightEnergy():int
		{
			return maxFlashlightEnergy;
		}

		public function setMaxFlashlightEnergy(value:int):void
		{
			maxFlashlightEnergy = value;
		}
		
		public function setCam(value:ACitrusCamera):void
		{
			_cam = value;
			_camPos = _cam.transformMatrix.transformPoint(new Point(0,0));
		}
	}
}