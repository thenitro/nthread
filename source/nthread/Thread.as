package nthread {
	import npooling.IReusable;
	import npooling.Pool;
	
	internal class Thread implements IReusable {
		private static var _pool:Pool = Pool.getInstance();
		
		public var method:Function;
		public var arguments:Array;
		
		private var _disposed:Boolean;
		
		public function Thread() {
			_disposed = false;
		};
		
		public static function get NEW():Thread {
			var result:Thread = _pool.get(Thread) as Thread;
			
			if (!result) {
				result = new Thread();
				_pool.allocate(Thread, 1);
			}
			
			return result;
		};
		
		public function get reflection():Class {
			return Thread;
		};
		
		public function get disposed():Boolean {
			return _disposed;
		};
		
		public function poolPrepare():void {
			method    = null;
			arguments = null;
		};
		
		public function dispose():void {
			_disposed = true;
			
			method    = null;
			arguments = null;
		};
	};
}