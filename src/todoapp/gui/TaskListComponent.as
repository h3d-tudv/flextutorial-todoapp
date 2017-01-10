package todoapp.gui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	import net.fproject.di.Injector;
	
	import todoapp.event.TaskEvent;
	import todoapp.model.Task;
	
	public class TaskListComponent extends SkinnableComponent
	{
		public function TaskListComponent()
		{
			super();
			Injector.inject(this);
		}
		
		[Bindable]
		public var dataProvider:ArrayCollection;

		[Bindable]
		public var dragEnabled:Boolean = true;
		
		[Bindable]
		public var dropEnabled:Boolean = true;
		
		[Bindable]
		public var dragMoveEnabled:Boolean = true;
		
		public function onDeleteTaskHandler(event:TaskEvent):void
		{
			if (event.data is Task && dataProvider)
				Alert.show("Are you sure you want to delete this task", "Delete Task confirm", Alert.OK | Alert.CANCEL,
					FlexGlobals.topLevelApplication as Sprite,
					function(e:CloseEvent):void
					{
						if((e.detail & Alert.OK) == Alert.OK)
						{
							dataProvider.removeItem(event.data);
						}
					});	
		}
		
		public function addButton_clickHandler(event:MouseEvent):void
		{
			if (taskNameInput && taskNameInput.text && taskNameInput.text.length > 0){
				var newTask:Task = new Task;		
				newTask.name = taskNameInput.text;
				dataProvider.addItem(newTask);
				taskNameInput.text = '';
			}
		}
		
		[SkinPart(required="true",type="static")]
		public var taskNameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="addButton_clickHandler")]
		public var addButton:Button;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dragEnabled="dragEnabled@")]
		[PropertyBinding (dropEnabled="dropEnabled@")]
		[PropertyBinding (dragMoveEnabled="dragMoveEnabled@")]
		[PropertyBinding (dataProvider="dataProvider@")]
		[EventHandling(event="deleteTask", handler="onDeleteTaskHandler")]
		public var taskList:List;
	}
}