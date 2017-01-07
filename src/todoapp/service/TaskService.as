package todoapp.service
{
	import mx.collections.ArrayCollection;
	
	import todoapp.model.Task;
	
	public class TaskService
	{
		protected var taskId:int;
		
		protected const TASK_NAMES:Array = ['Get some food', 'Feed the cat', 'Buy a gift for mom', 'Set up Site surveyor', 'Summit planning permission', 'Send presentation to professor', 'Return book to the library', 'Take out the trash', 'Send invitations', 'Go to the bank'];
		
		protected var tasks:ArrayCollection;
		
		public function TaskService()
		{
			taskId = 1;
			tasks = new ArrayCollection;
			
			for each (var taskName:String in TASK_NAMES){
				var task:Task = new Task;
				task.id = taskId++;
				task.name = taskName;
				tasks.addItem(task);
			}
		}
		
		private static var _instance:TaskService;
		public static function getInstance():TaskService
		{
			if (_instance == null)
				_instance = new TaskService();
			return _instance;
		}
		
		
		public function find(completeCallback:Function, failCallback:Function=null):void
		{
			var results:ArrayCollection = new ArrayCollection;
			for each (var task:Task in tasks)
			{
				results.addItem(task.clone());
			}
			completeCallback(results);
		}
		
		private function findById(id:int):Task
		{
			if (isNaN(id))
				return null;
			for each (var task:Task in tasks){
				if (task.id == id)
					return task;
			}
			return null;
		}
		public function findOne(id:int, completeCallback:Function, failCallback:Function=null):void
		{
			var task:Task = findById(id);
			if (task != null)
				completeCallback(task.clone());
			else
				completeCallback(null);
		}
		
		public function save(task:Task, completeCallback:Function, failCallback:Function=null):void
		{
			if (isNaN(task.id) || task.id == 0)
				task.id = taskId++;
			else
				taskId = (task.id >= taskId) ? task.id + 1 : taskId;
			
			var oldTask:Task = findById(task.id);
			if (oldTask != null)
				task.clone(oldTask); //update
			else
				tasks.addItem(task); //add
			
			completeCallback(task.id);
		}
		
		public function remove(data:Object, completeCallback:Function, failCallback:Function=null):void
		{
			var id:Number;
			var result:Boolean;
			
			if (data is Number || data is String)
				id = Number(data);
			else if (data.hasOwnProperty('id'))
				id = Number(data['id']);
			
			var task:Task = findById(id);
			if (task != null) 
				completeCallback(tasks.removeItem(task))
			else
				completeCallback(false);
		}
		
	}
}
