package todoapp.model
{
	public class Task
	{
		[Bindable]
		public var id:int;
		[Bindable]
		public var name:String;
		[Bindable]
		public var description:String;
		[Bindable]
		public var status:Status;
		
		public function clone(target:Task=null):Task
		{
			if(target == null)
				target = new Task;
			target.id = this.id;
			target.name = this.name;
			target.description = this.description;
			target.status = this.status;
			return target;
		}
	}
}