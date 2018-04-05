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
	addChatmessage("{" Color.Main "}Auto-Walk State: {" Color.Main "}" (AUTO_WALK_MODE := !AUTO_WALK_MODE))	
return

~2::
DisableCheckpoint()
_RandomCheckpoint()
SearchCP(5.0)

return

~3::
reload
return


Dist(_p1,_p2){
	return Sqrt((_p1[1]-_p2[1])*(_p1[1]-_p2[1])+(_p1[2]-_p2[2])*(_p1[2]-_p2[2])+(_p1[3]-_p2[3])*(_p1[3]-_p2[3]))
}

SearchCP(Range)
{
	While(A_Index <= 360)
	{
		if isObject(CalcScreenCoords(_Marker:=CoordsFromRedmarker(),50))
		{
			for	_i, m in _Marker
			{
				if !m 
				{
					FOUND_CP := False
					break					
				}
			}
			
			_Player := GetPlayerCoordinates()
			if DEBUG_MODE
			{
				addChatmessage("{" Color.Main "}Checkpooint - {" Color.Value "}Focused!")
				addChatmessage("{" Color.Main "}Checkpoint Position! {" Color.Value "}" _Marker[1] "{" Color.Main "} - {" Color.Value "}"  _Marker[2] "{" Color.Main "} - {" Color.Value "}"  _Marker[3])
				addChatmessage("{" Color.Main "}Player Position! {" Color.Value "}" _Player[1] "{" Color.Main "} - {" Color.Value "}"  _Player[2] "{" Color.Main "} - {" Color.Value "}"  _Player[3])
				addChatmessage("{" Color.Main "}Player Distance to Marker {" Color.Value "}" Round(odist:=Dist(_Player,_Marker)) "{" Color.Main "}m")
				addChatmessage("{" Color.Main "}Playerstate: {" Color.Value "}Auto-Walk Online!")
			}
			FOUND_CP := True
			break
		}
		else
			SetCameraAngleX(A_Index)
		
		AUTO_WALK_MODE ? "" : break
	}
	return FOUND_CP ? MoveToCP(Range,_Player,_Marker) : -1
}
return

MoveToCP(Range,PlayerPos,MarkerPos)
{
	if !IsMarkerCreated() || !AUTO_WALK_MODE || !isObject(PlayerPos) || !isObject(MarkerPos) || !Old_Dist || !Range
		return 0

	Send {w Down}

	oDist:=Dist(PlayerPos,MarkerPos)
	CP_REACHED := False

	Loop
	{
		if GetKeyState("x" ,"P"){
			Send {w}
			addChatmessage("Loop interrupted by userinput")
			break
		}
		
		if InRangeOf2D(MarkerPos,Range)
		{
			if DEBUG_MODE
				addChatmessage("{" Color.Main "}Checkpoint reached! {" Color.Value "}Auto-Walk Offline!")	
			Send {w}
			CP_REACHED := True
			break
		}
		
		if(oDist < ndist)
			break 
		else
			oDist:=Dist(PlayerPos,MarkerPos)
		
		AUTO_WALK_MODE ? "" : break
	}
	return !!CP_REACHED
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
