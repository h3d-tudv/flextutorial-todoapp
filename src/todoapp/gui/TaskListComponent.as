package todoapp.gui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.supportClasses.SkinnableComponent;
	
	import net.fproject.di.Injector;
	
	import todoapp.event.TaskEvent;
	import todoapp.model.Task;
	import todoapp.service.TaskService;
	
	public class TaskListComponent extends SkinnableComponent
	{
		[Bindable]
		public var tasks:ArrayCollection;
		
		public function TaskListComponent()
		{
			super();
			Injector.inject(this);
			addEventListener(FlexEvent.INITIALIZE, module_initializeHandler);
		}
		
		public function get taskService():TaskService
		{
			return TaskService.getInstance();
		}
		
		protected function module_initializeHandler(event:FlexEvent):void
		{
			taskService.find(
				function(result:ArrayCollection):void
				{
					tasks = result;
				}
			);	
		}
		
		public function onDeleteTaskHandler(event:TaskEvent):void
		{
			if (event.data is Task && tasks)
				Alert.show("Are you sure you want to delete this task", "Delete Task confirm", Alert.OK | Alert.CANCEL,
					FlexGlobals.topLevelApplication as Sprite,
					function(e:CloseEvent):void
					{
						if((e.detail & Alert.OK) == Alert.OK)
						{
							taskService.remove(event.data,
								function(result:Boolean):void
								{
									if (result)
										tasks.removeItem(event.data);
								});	
						}
					});	
		}
		
		public function addButton_clickHandler(event:MouseEvent):void
		{
			if (taskNameInput && taskNameInput.text && taskNameInput.text.length > 0){
				var newTask:Task = new Task;		
				newTask.name = taskNameInput.text;
				taskService.save(newTask,
					function(result:int):void
					{
						newTask.id = result;
					});	
				tasks.addItem(newTask);
				taskNameInput.text = '';
			}
		}
		
		[SkinPart(required="true",type="static")]
		public var taskNameInput:TextInput;
		
		[SkinPart(required="true",type="static")]
		[EventHandling(event="click", handler="addButton_clickHandler")]
		public var addButton:Button;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dataProvider="tasks@")]
		[EventHandling(event="deleteTask", handler="onDeleteTaskHandler")]
		public var taskList:List;
	}
}