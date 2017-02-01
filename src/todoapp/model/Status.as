package todoapp.model
{
	public class Status
	{
		[Bindable]
		public var id:int;
		
		[Bindable]
		public var name:String;
		
		[Bindable]
		public var description:String;
		
		public function clone(target:Status=null):Status
		{
			if(target == null)
				target = new Status;
			target.id = this.id;
			target.name = this.name;
			target.description = this.description;
			return target;
		}
	}
}