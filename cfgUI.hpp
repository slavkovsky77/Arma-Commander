// Defines and forward declarations
// @TODO: Link these files directly from a3 source, do not use own copies
#include "ui\defineDIKCodes.inc"
#include "ui\defineResincl.inc"
#include "ui\defineResinclDesign.inc"
#include "ui\rsccommon.inc"
#include "ui\defineCommon.inc"
#include "cfgScriptPaths.hpp"
#include "ui\defineResinclDesign.inc"

#define COLOR_LINE_SELECTED	{0.7,0.6,0,1} 

class RscButton;
class RscText;
class VScrollbar;
class HScrollbar;

class RscACButton : RscButton
{
	shadow = 0; // Shadow (0 - none, 1 - N/A, 2 - black outline)
	colorBackground[] = {1.0,1.0,1.0,0.2};
	colorFocused[] = {1.0,1.0,1.0,0.2};
	colorBackgroundActive[] = {1.0,1.0,1.0,0.4};
	colorBackgroundDisabled[] = {0,0,0,0};
	blinkingPeriod = 0;
};
class RscACCommandButton : RscACButton
{
	colorBackground[] = {1.0,1.0,1.0,0.0};
	colorFocused[] = {1.0,1.0,1.0,0.2};
	colorBackgroundActive[] = {1.0,1.0,1.0,0.4};
	colorBackgroundDisabled[] = {0,0,0,0};
	blinkingPeriod = 0;
};


class RscAcText: RscText
{
	style = ST_CENTER;
};

class RscAcActionsList
{
	idc = -1;
	x = safeZoneX + safeZoneW - 11 * GUI_GRID_W;
	y = 0.4 + 3.5 * GUI_GRID_H;
	w = 10 * GUI_GRID_W;
	h = 8 * GUI_GRID_H;

	// Mandatory config
	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 0.9 * GUI_GRID_H;
	headerHeight = 0.9 * GUI_GRID_H;
	firstIDC = 42000;
	lastIDC = 44999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};

	// Highlight color, needs to have the same color
	selectedRowColorFrom[] = COLOR_LINE_SELECTED;
	selectedRowColorTo[] = COLOR_LINE_SELECTED;

	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0.2 * GUI_GRID_W;
			columnW = 0.6 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 0.6 * GUI_GRID_H;
		};
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0.8 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Column3
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 7 * GUI_GRID_W;
			columnW = 3 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
		};
	};

	class RowTemplate
	{
		class RowBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class WaypointIcon
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 1 * GUI_GRID_H;
		};
		
		class WaypointTextButton
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 1 * GUI_GRID_W;
			columnW = 9 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
		};
	};
};

class RscAcGroupInfo
{
	idc = -1;
	x = safeZoneX + safeZoneW - 11 * GUI_GRID_W;
	y = 0.4;
	w = 10.1 * GUI_GRID_W;
	h = 4.5 * GUI_GRID_H;

	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 0.90 * GUI_GRID_H;
	headerHeight = 0.90 * GUI_GRID_H;
	firstIDC = 45000;
	lastIDC = 48999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	class RowTemplate
	{
		class RowBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 1 * GUI_GRID_H;
		};
		
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
		};
		class Column3
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 6 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
		};
	};
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		// Unit Icon - Rank or Type
		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		// Text: Battalion name
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1.2 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		class Column3
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 6 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 1 * GUI_GRID_H;
		};
	};
};
class RscAcBaseInfo
{
	idc = -1;
	x = safeZoneX + safeZoneW - 11 * GUI_GRID_W;
	y = 0.4;
	w = 10.1 * GUI_GRID_W;
	h = 4.5 * GUI_GRID_H;
	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 0.90 * GUI_GRID_H;
	headerHeight = 0.90 * GUI_GRID_H;
	firstIDC = 45000;
	lastIDC = 48999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	class RowTemplate
	{
		class RowBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 1 * GUI_GRID_H;
		};
		
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			//controlH = 1 * GUI_GRID_H;
		};
		class Column3
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 6 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			//controlH = 1 * GUI_GRID_H;
		};
	};
	
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 10 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		// Unit Icon - Rank or Type
		class BaseIcon
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};

		class BaseText
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1.2 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class PercentCaptured
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 8 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
	};
};		

class RscAcBattalionInfo
{
	idc = -1;
	x = safeZoneX + safeZoneW - 17 * GUI_GRID_W;
	y = safeZoneY + safeZoneH - 3 * GUI_GRID_H;
	w = 16.1 * GUI_GRID_W;
	h = 2 * GUI_GRID_H;
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 0.90 * GUI_GRID_H;
	headerHeight = 0.90 * GUI_GRID_H;
	firstIDC = 45000;
	lastIDC = 48999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};

	class RowTemplate
	{
		class ColumnBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 16 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class RequisitionIcon
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		class RequisitionPoints
		{
			controlBaseClassPath[] = {"RscStructuredText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 3 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		class TimeToPoints
		{
			controlBaseClassPath[] = {"RscStructuredText"};
			columnX = 2.5 * GUI_GRID_W;
			columnW = 6 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		class RequestButton
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 10 * GUI_GRID_W;
			columnW = 5.7 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 3 * GUI_GRID_CENTER_H;
			text = "REQUISITION";
			tooltip = "Request supplies or reinforcements";
		};
	};
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 16 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 12 * GUI_GRID_W;
			controlOffsetY = 0;
		};
	};
};

// Buying screen
class RscAcBuyList
{
	idc = -1;
	x = safeZoneX + safeZoneW - 16 * GUI_GRID_W;
	//y = safeZoneY + safeZoneH - 5 * GUI_GRID_H;
	//x = 1 - 1 * GUI_GRID_W;
	y = safeZoneH * 0.45;
	w = 15 * GUI_GRID_W;
	h = 11 * GUI_GRID_H;
	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 1 * GUI_GRID_H;
	headerHeight = 1 * GUI_GRID_H;
	firstIDC = 45000;
	lastIDC = 48999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	class RowTemplate
	{
		class RowBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 15 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class UnitsRemaining
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0 * GUI_GRID_W;
			columnW = 2 * GUI_GRID_W;
			controlOffsetY = 0;
			//style = ST_CENTER;
		};
		class Name
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1.5 * GUI_GRID_W;
			columnW = 8.5 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Cost
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 9 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		class RpIcon
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 10 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		class RequisitionButton
		{
			controlBaseClassPath[] = {"RscACButton"};
			columnX = 11 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
	};
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 15 * GUI_GRID_W;
			controlOffsetY = 0;
		};

		class Column1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0 * GUI_GRID_W;
			columnW = 1 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
		class Column2
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 9 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Column3
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 10 * GUI_GRID_W;
			columnW = 3 * GUI_GRID_W;
			controlOffsetY = 0;
		};
	};
};

class RscAcScoreInfo
{
	idc = -1;
	x = safeZoneX + safeZoneW - 17 * GUI_GRID_W;
	y = 0 + safeZoneY + 3 * GUI_GRID_H;
	w = 16.01 * GUI_GRID_W;
	h = 2 * GUI_GRID_H;
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 1.9 * GUI_GRID_H;
	headerHeight = 1.9 * GUI_GRID_H;
	firstIDC = 45000;
	lastIDC = 48999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};

	class RowTemplate
	{
	/*
		class ColumnBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 16 * GUI_GRID_W;
			controlOffsetY = 0;
		};
		class Timer
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 1 * GUI_GRID_W;
			columnW = 12 * GUI_GRID_W;
			controlOffsetY = 0;
		};
	*/
	};
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 16 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 2 * GUI_GRID_H;
		};

		class BatFlag1
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 0.5 * GUI_GRID_W;
			columnW = 2.5 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 2 * GUI_GRID_H;
		};
		class BatText1
		{
			controlBaseClassPath[] = {"RscAcText"};
			columnX = 3 * GUI_GRID_W;
			columnW = 2 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 2 * GUI_GRID_H;
		};

		class BatTimer
		{
			controlBaseClassPath[] = {"RscAcText"};
			columnX = 6 * GUI_GRID_W;
			columnW = 4 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 2 * GUI_GRID_H;
		};

		class BatText2
		{
			controlBaseClassPath[] = {"RscAcText"};
			columnX = 11 * GUI_GRID_W;
			columnW = 2 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 2 * GUI_GRID_H;
		};

		class BatFlag2
		{
			controlBaseClassPath[] = {"RscPictureKeepAspect"};
			columnX = 13 * GUI_GRID_W;
			columnW = 2.5 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 2 * GUI_GRID_H;
		};
	};
};

class RscAcCommanderInfo
{
	idc = -1;
	x = safeZoneX + safeZoneW - 9 * GUI_GRID_W;
	y = 0 + safeZoneY + 6 * GUI_GRID_H;
	w = 8.01 * GUI_GRID_W;
	h = 1 * GUI_GRID_H;
	selectedRowColorFrom[] = {0,0,0,0};
	selectedRowColorTo[] = {0,0,0,0};

	type = CT_CONTROLS_TABLE;
	style = SL_TEXTURES;
	lineSpacing = 0.0 * GUI_GRID_H;
	rowHeight = 1.9 * GUI_GRID_H;
	headerHeight = 1.9 * GUI_GRID_H;
	firstIDC = 49000;
	lastIDC = 49999;
	selectedRowAnimLength = 1.2;
	class VScrollBar: ScrollBar {};
	class HScrollBar: ScrollBar {};

	class RowTemplate
	{
	};
	class HeaderTemplate
	{
		class HeaderBackground
		{
			controlBaseClassPath[] = {"RscText"};
			columnX = 0;
			columnW = 8 * GUI_GRID_W;
			controlOffsetY = 0;
			controlH = 1 * GUI_GRID_H;
		};

		class CommanderButton
		{
			controlBaseClassPath[] = {"RscACCommandButton"};
			columnX = 0 * GUI_GRID_W;
			columnW = 8 * GUI_GRID_W;
			controlOffsetY = 0.0 * GUI_GRID_H;
			controlH = 1 * GUI_GRID_H;
		};
	};
};
