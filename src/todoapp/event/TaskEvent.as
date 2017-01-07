package todoapp.event
{
	import flash.events.Event;
	
	public class TaskEvent extends Event
	{
		private var _data:Object;
		public function get data():Object
		{
			return _data;
		}
		
		public function TaskEvent(type:String, data:Object)
		{
			_data = data;
			super(type);
		}
		
		public static const DELETE_TASK:String = "deleteTask";
	}
}