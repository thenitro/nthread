package nthread {
	import flash.errors.IllegalOperationError;
	import flash.utils.getTimer;
	
	import npooling.Pool;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class Threader extends EventDispatcher {
		private static var _pool:Pool = Pool.getInstance();
		
		private var _threadsStack:Vector.<Thread>;
		
		private var _inited:Boolean;
		
		private var _maxTime:uint;
		private var _maxIterations:int;
		
		private var _executed:uint     = 0;
		private var _perIteration:uint = 0;
		private var _startedWith:uint  = 0;
		
		public function Threader() {
			super();
		};
		
		public function get currentThreadSize():uint {
			return _threadsStack.length;
		};
		
		public function get executed():uint {
			return _executed;
		};
		
		public function get startedWith():uint {
			return _startedWith;
		};
		
		public function init(pMaxTime:uint, pMaxIterations:int):void {
			_inited = true;
			
			_maxTime       = pMaxTime;
			_maxIterations = pMaxIterations;
			
			_threadsStack = new Vector.<Thread>();
		};
		
		public function purge():void {
			if (!_inited) {
				throw new IllegalOperationError("Threader.purge: NOT inited!");
				return;
			}
			
			for each (var thread:Thread in _threadsStack) {
				_pool.put(thread);
			}
			
			_threadsStack.length = 0;
		};
		
		public function addThread(pCallback:Function, pArguments:Array = null):void {
			if (!_inited) {
				throw new IllegalOperationError("Threader.addThread: NOT inited!");
				return;
			}
			
			if (!pCallback) {
				throw new ArgumentError("Threader.addThread: pCallback cannot be null!");
				return;
			}
			
			var thread:Thread = Thread.NEW;
				
				thread.method    = pCallback;
				thread.arguments = pArguments;
			
			_threadsStack.push(thread);
		};
		
		public function update():void {
			if (!_inited) {
				return;
			}
			
			manageThreads();
		};
		
		private function manageThreads():void {
			var startTime:uint = getTimer();
			var runTime:uint   = 0;
			var stackSize:uint = currentThreadSize;
			
			var arguments:Array;
			
			if (!_startedWith || _threadsStack.length > _startedWith) {
				_startedWith = _threadsStack.length;
			}
			
			while (runTime < _maxTime) {
				var thread:Thread = _threadsStack.shift() as Thread;
				if (!thread) break;
				
				arguments = thread.arguments;
				
				if (arguments) {
					thread.method.apply(null, arguments);
				} else {
					thread.method();
				}
				
				_pool.put(thread);
				
				_executed++;
				_perIteration++;
				
				runTime = getTimer() - startTime;
				
				if (_maxIterations != -1 && _perIteration > _maxIterations) {
					 break;
				}
			}
			
			_perIteration = 0;
			
			if (_threadsStack.length == 0) {
				_startedWith = 0;
				_executed = 0;
				
				dispatchEventWith(Event.COMPLETE);
			}
		};
	};
}