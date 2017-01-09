package todoapp.gui
{
	import mx.collections.ArrayCollection;
	import mx.controls.AdvancedDataGrid;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.IndexChangeEvent;
	
	import net.fproject.collection.CollectionChangeManager;
	import net.fproject.di.Injector;
	
	import todoapp.component.TaskDetail;
	import todoapp.model.Task;
	import todoapp.service.TaskService;
	
	public class TaskGridView extends SkinnableComponent
	{
		[Bindable]
		public var selectedTask:Task;
		
		[Bindable]
		public var tasks:ArrayCollection;
		
		public function TaskGridView()
		{
			super();
			Injector.inject(this);
			addEventListener(FlexEvent.INITIALIZE, module_initializeHandler);
			addEventListener(FlexEvent.CREATION_COMPLETE, module_creationComplete);
		}
		
		public function get taskService():TaskService
		{
			return TaskService.getInstance();
		}
		
		public function get collectionChangeManager():CollectionChangeManager
		{
			return CollectionChangeManager.getInstance();
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
		
		protected function module_creationComplete(event:FlexEvent):void
		{
			if (taskGrid)
				taskGrid.addEventListener(IndexChangeEvent.CHANGE, taskGrid_changeHandler);
		}
		
		protected function taskGrid_changeHandler(event:ListEvent):void
		{
			if (taskGrid)
				selectedTask = taskGrid.selectedItem as Task;
		}
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding (dataProvider="tasks@")]
		public var taskGrid:AdvancedDataGrid;
		
		[SkinPart(required="true",type="static")]
		[PropertyBinding(task="selectedTask@")]
		public var taskDetail:TaskDetail;
	}
}