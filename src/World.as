package 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.display.MovieClip;
	import org.ascollada.physics.DaeBox;
	
	import Box2D.Dynamics.b2World;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Common.Math.b2Transform;
	import Box2D.Dynamics.Joints.b2MouseJoint
	import Box2D.Dynamics.Joints.b2MouseJointDef
	
	//入力系、リアルタイム取得。
	import General.Input;
	
	/**
	 * ...
	 * @author mimori
	 */
	public class World extends Sprite 
	{
		private const PIXELS_TO_METRE:int = 30;
		private const SWF_HALF_WIDTH:int = 400;
		private const SWF_HEIGHT:int = 600;
		
		private var _world:b2World;
		protected var _input:Input;
		protected var _mouseJoint:b2MouseJoint;
		
		protected var _mouseXWorldPhys:Number;
		protected var _mouseYWorldPhys:Number;
		protected var _mouseXWorld:Number;
		protected var _mouseYWorld:Number;
		protected var _mousePVec:b2Vec2 = new b2Vec2();
		
		//protected var body:b2Body;
		
		protected var _bp:Array	=	new Array;
		
		protected var phyData:Vector.<physicData>	=	new Vector.<physicData>();
		
		
		//texture
		protected var square:Sprite	=	new Sprite();
		
		public function World(stg:Stage,debugSprite:Sprite):void 
		{
			
			//物理世界を作成、この場合は重力 10 m/ss
			_world = new b2World(new b2Vec2(0,10),true);

			CreateRoom.create(800, 600, 30, _world);
			//TestRagdoll.createRagdoll(_world, 10);
			//Bridge.createBridge(_world, 30);
			
			//-----------------------------------------------------------------------
			
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = b2Body.b2_dynamicBody;//物体のタイプ
			bodyDef.angle = Math.PI / 180 * 30;//30°//角度の設定
			bodyDef.position.Set(400 / PIXELS_TO_METRE, 5);//場所のセット
			var sandbag:b2Body = _world.CreateBody(bodyDef);
			var dynamicBox:b2PolygonShape = new b2PolygonShape();
			dynamicBox.SetAsBox(1,6);//大きさのセット
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = dynamicBox;
			fixtureDef.density = 10;			//密度
			fixtureDef.friction = 10;			//摩擦
			sandbag.CreateFixture(fixtureDef);
			fixtureDef.restitution	=	0.9;	//反発係数
			
			//---------------------------------------------------------------------------
			
			//用意する関節は６箇所
			for (var i = 0; i <= 6; i++) {
				phyData.push(new physicData());	
			}

			var bodyDef:b2BodyDef = new b2BodyDef();
			
			bodyDef.type = b2Body.b2_dynamicBody;//物体のタイプ
			bodyDef.angle = Math.PI / 180 * 30;//30°//角度の設定
			bodyDef.position.Set(SWF_HALF_WIDTH / PIXELS_TO_METRE, 5);//場所のセット
			//物理世界にクリップをセット
			//var body:b2Body = _world.CreateBody(bodyDef);
			for each (var item:physicData in phyData) 
			{
				item.body	=	_world.CreateBody(bodyDef);
			}
			//phyData[0].body	= _world.CreateBody(bodyDef);
			
			
			var dynamicCircle:b2CircleShape = new b2CircleShape();
			dynamicCircle.SetRadius(0.5);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = dynamicCircle;
			fixtureDef.density = 10;			//密度
			fixtureDef.friction = 10;			//摩擦
			//fixtureDef.restitution	=	0.9;	//反発係数
			
			for each (item:physicData in phyData) 
			{
				item.body.CreateFixture(fixtureDef);
			}

			//var debugSprite:Sprite = new Sprite();
			stg.addChild(debugSprite);
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(PIXELS_TO_METRE);
			debugDraw.SetLineThickness( 1.0);
			debugDraw.SetAlpha(1);
			debugDraw.SetFillAlpha(0.4);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit);
			_world.SetDebugDraw(debugDraw);

			
			//_input = new Input(stage);
			_input = new Input(stg);
			
			//アップデートイベントはメイン側で所持
			//addEventListener(Event.ENTER_FRAME, update);
			
			
			for each (var item:physicData in phyData) 
			{
				var md:b2MouseJointDef = new b2MouseJointDef();
				md.bodyA = _world.GetGroundBody();
				md.target.Set(item.body.GetPosition().x, item.body.GetPosition().y);//マウスに近づく物体の基準点
				md.bodyB = item.body;
				md.collideConnected = false;
				md.frequencyHz	=	60;
				md.dampingRatio	=	1;
				md.maxForce = 3000000.0;// * body.GetMass();//マウスに近づく強さ
				item.mouseJoint = _world.CreateJoint(md) as b2MouseJoint;//設定完了
				item.body.SetAwake(true);//これがoffだと物体が動かん
			}
			
		}
		
		public function update(e: Event):void
		{
			var timeStep:Number = 1 / 30;
			var velocityIterations:int = 10;
			var positionIterations:int = 10;

			UpdateMouseWorld();
			MouseDrag();
			
			_world.Step(timeStep,velocityIterations,positionIterations);
			_world.ClearForces();
			_world.DrawDebugData();
			
			
			//square.x	=	body.GetPosition().x * PIXELS_TO_METRE;
			//square.y	=	body.GetPosition().y * PIXELS_TO_METRE;
			//square.rotation	=	body.GetAngle() * 180 / Math.PI;
		}
		
		protected function MouseDrag():void
		{
			var	i:int	= 0;
			for each (var item:physicData in phyData) 
			{
				var p2:b2Vec2 = new b2Vec2(_bp[i].x / PIXELS_TO_METRE, _bp[i].y / PIXELS_TO_METRE);
				item.mouseJoint.SetTarget(p2);//ジョイントのターゲッティング
				i++;
			}
			
			//if (_mouseJoint)
			//{
				//var p2:b2Vec2 = new b2Vec2(_mouseXWorldPhys, _mouseYWorldPhys);
				//body.SetPosition(p2);
				//phyData[0].mouseJoint.SetTarget(p2);//ジョイントのターゲッティング
			//}
		}
		
		/**
		 * 
		 */
		public function bodyUpdate(bp:Array):void {
			_bp	=	bp;
		}
		
		protected function UpdateMouseWorld():void
		{
			
			_mouseXWorldPhys = Object(_bp[0]).x / PIXELS_TO_METRE;
			_mouseYWorldPhys = Object(_bp[0]).y / PIXELS_TO_METRE;
			//_mouseXWorldPhys	=	200 / PIXELS_TO_METRE;
			//_mouseYWorldPhys = (Input.mouseY) / PIXELS_TO_METRE;
			
			//trace(_mouseYWorldPhys);
			
			//_mouseXWorld = (Input.mouseX);
			//_mouseYWorld = (Input.mouseY);
		}
		
		protected function createSquare():void {
			square.x =	30;
			square.y =	30;
			square.graphics.beginFill(0xFFCC00);
			square.graphics.drawRect(-PIXELS_TO_METRE,-PIXELS_TO_METRE, 2 * PIXELS_TO_METRE, 2 * PIXELS_TO_METRE);
			addChild(square);
		}
		
	}
	
}