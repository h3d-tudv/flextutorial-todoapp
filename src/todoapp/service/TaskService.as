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


		public function find(completeCallback:Function = null, failCallback:Function=null):void
		{
			var results:ArrayCollection = new ArrayCollection;
			for each (var task:Task in tasks)
			{
				results.addItem(task.clone());
			}
			if (completeCallback != null)
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
		public function findOne(id:int, completeCallback:Function = null, failCallback:Function=null):void
		{
			var task:Task = findById(id);
			if (task != null && completeCallback != null)
				completeCallback(task.clone());
			else if (completeCallback != null)
				completeCallback(null);
		}
		
		public function save(model:Object, completeCallback:Function=null, failCallback:Function=null):void
		{
			var task:Task = model as Task;
			if (task == null)
			{
				if (failCallback != null)
					failCallback(false);
				return;
			}
			if (isNaN(task.id) || task.id == 0)
				task.id = taskId++;
			else
				taskId = (task.id >= taskId) ? task.id + 1 : taskId;
			
			var oldTask:Task = findById(task.id);
			if (oldTask != null)
				task.clone(oldTask); //update
			else
				tasks.addItem(task); //add
			if (completeCallback != null)
				completeCallback(task.id);
		}
		
		public function remove(data:Object, completeCallback:Function=null, failCallback:Function=null):void
		{
			var id:Number;
			var result:Boolean;
			
			if (data is Number || data is String)
				id = Number(data);
			else if (data.hasOwnProperty('id'))
				id = Number(data['id']);

			var task:Task = findById(id);
			if (task != null)
				tasks.removeItem(task);
			if (completeCallback != null)
				completeCallback(true);
		}
		
		public function batchSave(models:Array, completeCallback:Function=null, failCallback:Function=null):void
		{
			var insertCount:int = 0;
			var updateCount:int = 0;
			for each (var model:Object in models)
			{
				if (model is Task){
					if (isNaN(Task(model).id) || Task(model).id == 0)
					{
						insertCount++;
					}
					else 
					{
						updateCount++;
					}
					save(model);
				}
			}
			var result:Object = {insertCount:insertCount, updateCount:updateCount, lastId:taskId};
			if (completeCallback != null)
				completeCallback(result);
		}
		
		public function batchRemove(items:Array, completeCallback:Function=null, failCallback:Function=null):void
		{
			for each (var item:Object in items){
				remove(item);				
			}
			if (completeCallback != null)
				completeCallback(item);
		}
	}
}
