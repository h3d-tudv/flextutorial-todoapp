package todoapp.component
{
	import spark.components.TextArea;
	import spark.components.TextInput;
	
	import todoapp.model.Status;

	public class StatusDialog extends DetailDialogBase
	{
		public function StatusDialog()
		{
			super();
		}
		
		public function get status():Status
		{
			return model as Status;	
		}
		
		public function get edittingStatus():Status
		{
			return temporaryModel as Status;
		}
		
		override protected function populateTemporaryModel(model:Object):void
		{
			temporaryModel = Status(model).clone();
		}
		
		override protected function apply():void
		{
			//Do không hiểu tại sao không binding được giá trị từ nameInput và statusDescription vào edittingStatus
			//Nên tạm thời gán thủ công. Sẽ tìm hiểu nguyên nhân sau
			edittingStatus.name = nameInput.text;
			edittingStatus.description = nameInput.text;
			
			edittingStatus.clone(status);
		}
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(text="temporaryModel.name@")]
		public var nameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(text="temporaryModel.description@")]
		public var statusDescription:TextArea;
	}
}