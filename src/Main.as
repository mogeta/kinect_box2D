package  {
		
	import adobe.utils.CustomActions;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import org.as3kinect.as3kinect;
	import org.as3kinect.as3kinectWrapper;
	import org.as3kinect.events.as3kinectWrapperEvent;
	
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.text.TextField;
	
	/**
	 * 起動クラス
	 */
	public class Main extends MovieClip{
		
		private var as3w:as3kinectWrapper;
		private var _canvas:BitmapData;
		private var _bmp:Bitmap;
		
		private var skipcount:int = 0;
		private var dcam:Boolean = true;
		
		private var console:TextField	=	new TextField;
		private var depth_cam:MovieClip	=	new MovieClip();
 
		public var world:World;
		public var canvas:Sprite	=	new Sprite;
		public var bp:Array	=	new Array();
		
		private var debug:Boolean	=	false;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			world	=	new World(stage,canvas);
			
			as3w = new as3kinectWrapper();
			as3w.addEventListener(as3kinectWrapperEvent.ON_DEPTH, got_depth);
			as3w.addEventListener(as3kinectWrapperEvent.ON_SKEL, got_skel);
			
			addChild(depth_cam);
			addChild(console);
			
			
			as3w.logConsole = console;
			
			_canvas = new BitmapData(as3kinect.IMG_WIDTH, as3kinect.IMG_HEIGHT, false, 0xFF000000);
			_bmp = new Bitmap(_canvas);
			depth_cam.addChild(_bmp);
			this.addEventListener(Event.ENTER_FRAME, ef);
			
		}
		
		private function ef(e:Event):void {
			
			as3w.getSkeleton();
			
			
			//スケルトン認識ができるまでループを行う。
			skipcount += 1;
			if (skipcount == 3 && dcam) { 
				skipcount = 0;  as3w.getDepthBuffer();
			}
			
			if (debug) {
				for (var i = 0; i <= 6; i++) {
					var o:Object	=	new Object;
					o.x	=	100;
					o.y	=	100;
					bp[i]	=	o;
				}
				world.bodyUpdate(bp);
				world.update(e);
			}
		}
		
		private function got_depth(event:as3kinectWrapperEvent):void{
			as3w.byteArrayToBitmapData(event.data, _canvas);
		}
		
		/**
		 * スケルトン獲得時に動作するフレーム
		 * @param	event
		 */
		private function got_skel(event:as3kinectWrapperEvent):void {
			dcam = false; 
			depth_cam.visible = false;
			
			var skel:Object = event.data;
			
			bp[0]	=	skel.head;
			bp[1]	=	skel.l_hand;
			bp[2]	=	skel.r_hand;
			bp[3]	=	skel.l_knee;
			bp[4]	=	skel.r_knee;
			bp[5]	=	skel.l_foot;
			bp[6]	=	skel.r_foot;
			
			world.bodyUpdate(bp);
			world.update(event);	
			//this.graphics.clear();
			
			canvas.graphics.lineStyle(3,0xFFFFFF);	
			drawLine(skel.head, skel.neck);
			
			drawLine(skel.neck, skel.l_shoulder);
			drawLine(skel.l_shoulder, skel.l_elbow);
			drawLine(skel.l_elbow, skel.l_hand);
			
			drawLine(skel.neck, skel.r_shoulder);
			drawLine(skel.r_shoulder, skel.r_elbow);
			drawLine(skel.r_elbow, skel.r_hand);
			
			drawLine(skel.l_shoulder, skel.torso);
			drawLine(skel.r_shoulder, skel.torso);
			
			drawLine(skel.torso, skel.l_hip);
			drawLine(skel.l_hip, skel.l_knee);
			drawLine(skel.l_knee, skel.l_foot);
			
			drawLine(skel.torso, skel.r_hip);
			drawLine(skel.r_hip, skel.r_knee);
			drawLine(skel.r_knee, skel.r_foot);
			
			drawLine(skel.l_hip, skel.r_hip);			   
		}
		
		private function drawLine(from:Object, to:Object):void{
			canvas.graphics.moveTo(from.x, from.y);
            canvas.graphics.lineTo(to.x, to.y);
			
		}
	}	
}