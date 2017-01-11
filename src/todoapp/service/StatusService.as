package todoapp.service
{
	import mx.collections.ArrayCollection;
	
	import todoapp.model.Status;
	
	public class StatusService
	{
		protected var statusId:int;
		
		protected const TASK_NAMES:Array = ['doing', 'done'];
		
		protected var statusCollection:ArrayCollection;
		
		public function StatusService()
		{
			statusId = 1;
			statusCollection = new ArrayCollection;
			
			for each (var statusName:String in TASK_NAMES){
				var status:Status = new Status;
				status.id = statusId++;
				status.name = statusName;
				statusCollection.addItem(status);
			}
		}
		
		private static var _instance:StatusService;
		public static function getInstance():StatusService
		{
			if (_instance == null)
				_instance = new StatusService();
			return _instance;
		}


		public function find(criteria:Object=null, completeCallback:Function = null, failCallback:Function=null):void
		{
			var results:ArrayCollection = new ArrayCollection;
			for each (var status:Status in statusCollection)
			{
				var match:Boolean = true;
				if (criteria != null)
					for (var key:String in criteria)
					{
						if (!status.hasOwnProperty(key) || status[key] != criteria[key])
						{
							match = false;
							break;
						}
					}
				
				if (match)
					results.addItem(status.clone());
			}
			if (completeCallback != null)
				completeCallback(results);
		}
		
		private function findById(id:int):Status
		{
			if (isNaN(id))
				return null;
			for each (var status:Status in statusCollection){
				if (status.id == id)
					return status;
			}
			return null;
		}
		public function findOne(id:int, completeCallback:Function = null, failCallback:Function=null):void
		{
			var status:Status = findById(id);
			if (status != null && completeCallback != null)
				completeCallback(status.clone());
			else if (completeCallback != null)
				completeCallback(null);
		}
		
		public function save(model:Object, completeCallback:Function=null, failCallback:Function=null):void
		{
			var status:Status = model as Status;
			if (status == null)
			{
				if (failCallback != null)
					failCallback(false);
				return;
			}
			if (isNaN(status.id) || status.id == 0)
				status.id = statusId++;
			else
				statusId = (status.id >= statusId) ? status.id + 1 : statusId;
			
			var oldStatus:Status = findById(status.id);
			if (oldStatus != null)
				status.clone(oldStatus); //update
			else
				statusCollection.addItem(status); //add
			if (completeCallback != null)
				completeCallback(status.id);
		}
		
		public function remove(data:Object, completeCallback:Function=null, failCallback:Function=null):void
		{
			var id:Number;
			var result:Boolean;
			
			if (data is Number || data is String)
				id = Number(data);
			else if (data.hasOwnProperty('id'))
				id = Number(data['id']);

			var status:Status = findById(id);
			if (status != null)
				statusCollection.removeItem(status);
			if (completeCallback != null)
				completeCallback(true);
		}
		
		public function batchSave(models:Array, completeCallback:Function=null, failCallback:Function=null):void
		{
			var insertCount:int = 0;
			var updateCount:int = 0;
			for each (var model:Object in models)
			{
				if (model is Status){
					if (isNaN(Status(model).id) || Status(model).id == 0)
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
			var result:Object = {insertCount:insertCount, updateCount:updateCount, lastId:statusId};
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
