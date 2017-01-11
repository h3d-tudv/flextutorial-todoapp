package todoapp.model
{
	public class Status
	{
		[Bindable]
		public var id:int;
		
		[Bindable]
		public var name:String;
		
		public function clone(target:Status=null):Status
		{
			if(target == null)
				target = new Status;
			target.id = this.id;
			target.name = this.name;
			return target;
		}
	}
}