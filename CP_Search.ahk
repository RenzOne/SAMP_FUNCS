#Persistent
#SingleInstance force
#include samp.ahk

global Color := {Main:"FFFFFF", Value:"FFAF8F"}
global DEBUG_MODE := True
global AUTO_WALK_MODE := False

return


~1::
if !DEBUG_MODE
	AUTO_WALK_MODE := !AUTO_WALK_MODE
else
	DebugMes("{" Color.Main "}Auto-Walk State: {" Color.Value "}" ((AUTO_WALK_MODE := !AUTO_WALK_MODE)?("Turned On"):("Turned Off")))	
return

~2::
DisableCheckpoint()
_RandomCheckpoint()
SearchCP(GetPlayerCoordinates(),5.0)
	
return

~3::
reload
return


Dist(_p1,_p2){
	return Sqrt((_p1[1]-_p2[1])*(_p1[1]-_p2[1])+(_p1[2]-_p2[2])*(_p1[2]-_p2[2])+(_p1[3]-_p2[3])*(_p1[3]-_p2[3]))
}

SearchCP(pPos,Range)
{
	if(!isObject(pPos) || !Range)
		return 0
	While(A_Index <= 360)
	{
		if !AUTO_WALK_MODE 
			break
			
		for	_i, m in _Marker
		{
			if !m 
			{
				FOUND_CP := False
				break					
			}
		}
		if FOUND_CP := isObject(CalcScreenCoords(_Marker:=CoordsFromRedmarker(),50))
			break
		else
			SetCameraAngleX(A_Index)
	}
	return FOUND_CP ? MoveToCP(Range,pPos,_Marker) : -1
}
return

MoveToCP(Range,PlayerPos,MarkerPos)
{
	if !IsMarkerCreated() || !AUTO_WALK_MODE || !isObject(PlayerPos) || !isObject(MarkerPos) || !Range
		return 0

	Send {w Down}

	_oldDist:=Dist(PlayerPos,MarkerPos)
	CP_REACHED := False

	Loop
	{
		if !AUTO_WALK_MODE 
			break

		_oldDist:=Dist(PlayerPos:=GetPlayerCoordinates(),MarkerPos:=CoordsFromRedmarker())
		
		if GetKeyState("x" ,"P"){
			Send {w}
			DebugMes("{" Color.Main "}Loop interrupted reason: {" Color.Value "}Userinput pushed panic button!")
			break
		}
		
		if CP_REACHED := InRangeOf2D(MarkerPos,Range){
			DebugMes("{" Color.Main "}Checkpoint reached! {" Color.Value "}Auto-Walk Offline!")	
			Send {w}
			break
		}
		
		if(_oldDist>_newdist:=Dist(PlayerPos,MarkerPos)){
			DebugMes("{" Color.Main "}Loop interrupted reason: {" Color.Value "}Distance to marker get bigger! (Has to get smaller!)")
			Send {w}
			break
		}
	}
	return !!(CP_REACHED)
}

_RandomCheckpoint()
{
	if IsMarkerCreated()
		DisableCheckpoint()

	CPos:=GetPlayerCoordinates()
	return SetCheckpoint(CPos[1]+RandEx(-80.0, 80.0),CPos[2]+RandEx(-80.0, 80.0),CPos[3], pSize)
}

RandEx(Min,Max){
	Random, rand, % Min, % Max
	return rand
}

DebugMes(Mes)
{
	return DEBUG_MODE ? addChatmessage(Mes) : 0
}
