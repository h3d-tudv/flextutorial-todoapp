package todoapp.component
{
	import flash.display.DisplayObject;
	
	import todoapp.component.DialogBase;

	public class DetailDialogBase extends DialogBase
	{
		public function DetailDialogBase()
		{
			super();
		}
		
		private var _temporaryModel:Object;
		
		[Bindable("propertyChange")]
		/**
		 * Temporary editing model. This object is used to bind with UI skin controls
		 */
		public function get temporaryModel():Object
		{
			return _temporaryModel;
		}
		
		/**
		 * @private
		 */
		public function set temporaryModel(value:Object):void
		{
			if (_temporaryModel != value)
			{
				var oldValue:Object = _temporaryModel;
				_temporaryModel = value;
				dispatchPropertyChangeEvent("temporaryModel", oldValue, value);
			}
		}
		
		private var _model:Object;

		[Bindable(event="propertyChange")]
		public function get model():Object
		{
			return _model;
		}

		public function set model(value:Object):void
		{
			_model = value;
			
			if(value != null)
				populateTemporaryModel(value);
			else
				temporaryModel = null;
		}

		
		public function show(model:Object, parent:DisplayObject, modal:Boolean,
							 closeFunction:Function = null, readOnly:Boolean=false):void
		{
			//Disconnect from current model
			this.model = null;
			this.model = model;
			this.showDialog(parent, modal, closeFunction);
		}
		
		/**
		 * Populate temporaty editing model from the input model 
		 * @param model
		 * 
		 */
		protected function populateTemporaryModel(model:Object):void
		{
			//Abstract method
		}
	}
}