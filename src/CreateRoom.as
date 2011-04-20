package  
{
	import Box2D.Dynamics.b2World;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Collision.Shapes.b2PolygonShape;
	
	
	/**
	 * ...
	 * @author mimori
	 */
	public class CreateRoom 
	{
		/**
		 * 部屋を作る
		 */
		public function CreateRoom() 
		{
			
		}
		
		/**
		 * 指定された大きさの箱を作る
		 * @param	w:int	...幅
		 * @param	h:int	...高さ
		 * @param	pix:int	...メートル / ピクセル
		 * @param	m_world:b2World	...物理空間
		 */
		public static function create(w:int, h:int,pix:int, m_world:b2World ) {
			
			// Create border of boxes
			var wall:b2PolygonShape = new b2PolygonShape();
			var wallBd:b2BodyDef = new b2BodyDef();
			var wallB:b2Body;
			
			//箱の大きさ
			wall.SetAsBox(5/pix, h/pix/2);
			
			// Left
			
			wallBd.position.Set( 0, h / pix / 2);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			
			// Right
			
			wallBd.position.Set(w/pix, h/ pix / 2);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			
			
			wall.SetAsBox(w / pix / 2, 5 / pix);
			
			// Top
			wallBd.position.Set(w / pix / 2, 0);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
			// Bottom
			wallBd.position.Set(w / pix / 2, h / pix);
			wallB = m_world.CreateBody(wallBd);
			wallB.CreateFixture2(wall);
		}
		
	}

}