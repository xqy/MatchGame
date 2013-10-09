package com.match.view.match{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class MatchLayout extends Sprite{
		
		public var main:MatchView;
		
		public var iconBmd:BitmapData;
		
		private var _cellWidth:int;
		private var _cellHeight:int;
		
		private var _tempX:Number;
		private var _tempY:Number
		
		private var _cellMatrix:Array;
		
		private var _iX:int;
		private var _iY:int;
		
		private var _hasChangeOver:Boolean;
		
		public function MatchLayout(main:MatchView)
		{
			this.main = main;
			this.iconBmd = ((new main.assets.iconBmp()) as Bitmap).bitmapData;
			this._cellWidth = this._cellHeight = int(iconBmd.width / 8);
			_hasChangeOver = false;
		}
		
		public function layout(data:Array):void
		{
			_cellMatrix = [];
			
			var temp:Array;
			var icon:CellIcon;
			for(var i:int = 0; i < Global.MATCH_COL; i++)
			{
				temp = data[i];
				_cellMatrix.push([]);
				for(var j:int = 0; j < Global.MATCH_ROW; j++)
				{
					icon = getBitmapData(temp[j]);
					addChild(icon);
					icon.x = i * (_cellWidth + 2);
					icon.y = (Global.MATCH_ROW - 1 - j) * (_cellHeight + 2);
					
					(_cellMatrix[_cellMatrix.length - 1] as Array).push(icon);
				}
			}
			
			main.checkCallBack();
			
			addListener();
		}
		
		private function addListener():void
		{
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		private function mouseDownHandler(event:MouseEvent):void
		{
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_tempX = this.mouseX;
			_tempY = this.mouseY;
			
			_iX = int(Math.floor(_tempX / (_cellWidth + 2)));
			_iY = Global.MATCH_ROW - 1 - int(Math.floor(_tempY / (_cellHeight + 2)));
			
			trace("选中的是第",_iX+ 1,"排第", _iY  + 1, "个");
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
			var tempX:int = int(Math.floor(this.mouseX / (_cellWidth + 2)));
			var tempY:int = 6 - int(Math.floor(this.mouseY / (_cellHeight + 2)));
			
			if(Math.abs(tempX - _iX) == 1 || Math.abs(tempY - _iY) == 1)
			{
				if(tempX >= 0 && tempX <= (Global.MATCH_ROW - 1) && tempX >= 0 && tempX <= (Global.MATCH_ROW - 1))
				{
					exchangeCell(new Point(_iX, _iY), new Point(tempX, tempY));
					if(this.hasEventListener(MouseEvent.MOUSE_MOVE))this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);  

				}
			}
		}
		
		public function exchangeCell(point1:Point, point2:Point):void
		{
			var temp:CellIcon;
			
			var cell1:CellIcon = _cellMatrix[point1.x][point1.y];
			var pp1:Point = new Point(point1.x * (_cellWidth + 2), ((Global.MATCH_ROW - 1) - point1.y) * (_cellHeight + 2));
			
			var cell2:CellIcon = _cellMatrix[point2.x][point2.y];
			var pp2:Point = new Point(point2.x * (_cellWidth + 2), ((Global.MATCH_ROW - 1) - point2.y) * (_cellHeight + 2));
			
			temp = _cellMatrix[point1.x][point1.y];
			_cellMatrix[point1.x][point1.y] = _cellMatrix[point2.x][point2.y];
			_cellMatrix[point2.x][point2.y] = temp;
			
			TweenLite.to(cell1,.3,{x:pp2.x, y:pp2.y, onComplete:function():void
			{
				if(_hasChangeOver)
				{
					main.exchangeCallBack([point1.x, point1.y,point2.x, point2.y]);
					_hasChangeOver = false;
				}
				else
					_hasChangeOver = true;
			}});
			TweenLite.to(cell2,.3,{x:pp1.x, y:pp1.y, onComplete:function():void
			{
				if(_hasChangeOver)
				{
					main.exchangeCallBack([point1.x, point1.y,point2.x, point2.y]);
					_hasChangeOver = false;
				}
				else
					_hasChangeOver = true;
			}});
			
			
		}
		
		public function exchange(point1:Point, point2:Point):void
		{
			var temp:CellIcon;
			
			var cell1:CellIcon = _cellMatrix[point1.x][point1.y];
			var pp1:Point = new Point(point1.x * (_cellWidth + 2), ((Global.MATCH_ROW - 1) - point1.y) * (_cellHeight + 2));
			
			var cell2:CellIcon = _cellMatrix[point2.x][point2.y];
			var pp2:Point = new Point(point2.x * (_cellWidth + 2), ((Global.MATCH_ROW - 1) - point2.y) * (_cellHeight + 2));
			
			TweenLite.to(cell1,.3,{x:pp2.x, y:pp2.y});
			TweenLite.to(cell2,.3,{x:pp1.x, y:pp1.y});
			
			temp = _cellMatrix[point1.x][point1.y];
			_cellMatrix[point1.x][point1.y] = _cellMatrix[point2.x][point2.y];
			_cellMatrix[point2.x][point2.y] = temp;
			
		}
		
		public function remove(data1:Array, data2:Array):void
		{
			var icon:CellIcon;
			var num0:int;
			for(var i:int = 0; i < Global.MATCH_COL; i++)
			{
				var cols:Array = _cellMatrix[i];
				num0 = 0;
				for(var j:int = 0; j < Global.MATCH_ROW; j++)
				{
					//移除方块,如果是0则移除,不是0则下移,调整方块的序列
					icon = cols[j];
					if(data1[i][j] == 0)
					{
						num0++;
						icon.remove();
						cols[j] = null;
					}
					else if(num0 > 0)
					{
						//下移并和前面的已经制空的序列位交换位置
						cols[j - num0] = cols[j];
						cols[j] = null;
						TweenLite.to(cols[j - num0],.3,{y:((6 - j + num0) * (this._cellHeight + 2)), onComplete:function():void
						{
							main.checkCallBack();
						}});
					}
				}
				//削减数组,去除已制空的序列位
				cols.splice((cols.length - num0), num0);
				var adds:Array = data2[i];
				for(var k:int = 0; k < adds.length; k++)
				{
					//新增方块
					icon = getBitmapData(adds[k]);
					addChild(icon);
					icon.x = i * (_cellHeight + 2);
					icon.y = - (k + 1) * (_cellHeight+ 2);
					TweenLite.to(icon,.3,{y:((adds.length - 1 - k) * (_cellHeight + 2)), onComplete:function():void
					{
						main.checkCallBack();
					}});
					cols.push(icon);
				}
			}
		}
		
		private function mouseUpHandler(event:MouseEvent):void
		{
			if(this.hasEventListener(MouseEvent.MOUSE_MOVE))this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);  
		}
		
		private function getBitmapData(type:int):CellIcon
		{
			var bmd:BitmapData = new BitmapData(this._cellWidth, this._cellHeight);
			bmd.copyPixels(this.iconBmd,new Rectangle(((type - 1) * _cellWidth), 0,this._cellWidth, this._cellHeight), new Point());
			return (new CellIcon(bmd));
		}
	}
}