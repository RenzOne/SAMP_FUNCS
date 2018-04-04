#Persistent
#SingleInstance force
#include samp.ahk
return


~1::
_RandomCheckpoint()
return

~2::
if SearchCP()
{
	if MoveToCP(5)
	{
		if IsMarkerCreated() && DisableCheckpoint()
			_RandomCheckpoint()
	}
	if SearchCP()
	{
		if MoveToCP(5)
		{
			if IsMarkerCreated() && DisableCheckpoint()
				_RandomCheckpoint()
		}
	}
}
return

MoveToCP(Range)
{
	if !IsMarkerCreated()
		return 0
		
	Send {w Down}
	CP_REACHED := False
	Loop
	{
		if GetKeyState("Alt" ,"P") && GetKeyState("x" ,"P")
		break
		
		if InRangeOf2D(CoordsFromRedmarker2D(),Range)
		{
			addChatmessage("Point Reached! Set new Checkpoint!")
			Send {w}
			CP_REACHED := True
			break
		}
	}
	return !!CP_REACHED
}

~3::
addChatmessage(x:=InRangeOf2D(CoordsFromRedmarker2D(),3.0))
if x
{
	addChatmessage("Checkpoint Reached! New Checkpoint will be setted!")
	Send {w}
	if(!IsMarkerCreated())
		_RandomCheckpoint()
	SearchCP()
}
return

:?:t/reload::
reload
return


Dist(_p1,_p2){
	dist := (_p1[1]-_p2[1])*(_p1[1]-_p2[1])+(_p1[2]-_p2[2])*(_p1[2]-_p2[2])+(_p1[3]-_p2[3])*(_p1[3]-_p2[3])
	addChatmessage(Sqrt(dist))
	return Sqrt(dist)
}

SearchCP()
{
	While(A_Index <= 360)
	{
		if CalcScreenCoords(_Marker:=CoordsFromRedmarker(),50,True)
		{
			_Player := GetPlayerCoordinates()
			addChatmessage("Checkpooint in Focus!")
			addChatmessage("Checkpoint Position! " _Marker[1] " - "  _Marker[2] " - "  _Marker[3])
			addChatmessage("Player Position! " _Player[1] " - "  _Player[2] " - "  _Player[3])
			addChatmessage("Player Distance to Marker " Dist([_Player[1]._Player[2],_Player[3]],_Marker) "m")
			addChatmessage("Playerstate: Start to walk!")
			Found := True
			break
		}
		else
			SetCameraAngleX(A_Index)
	}
	return Found ? True : SearchCP()
}
return

_RandomCheckpoint()
{
	if IsMarkerCreated()
		DisableCheckpoint()

	CPos:=GetPlayerCoordinates()
	return SetCheckpoint(CPos[1]+RandEx(-45.0, 45.0),CPos[2]+RandEx(-45.0, 45.0),CPos[3]+0.5, pSize)
}

RandEx(Min,Max){
	Random, rand, % Min, % Max
	return rand
}

; SAMP Funcs
/*

global VAR_PI := 4*ATan(1)
global VAR_RADIANT := 0.017453292519943
global VAR_DEGREE := 57.295779513082

global ADDR_CAMERA_ROTATION     			:= 0xB6F178
global ADDR_CAMERA_POS_X        			:= 0xB6F9CC
global ADDR_CAMERA_POS_Y        			:= 0xB6F9D0
global ADDR_CAMERA_CURR_X       			:= 0xB6F258
global ADDR_CAMERA_ANGLE_X      			:= 0xB6F104
global ADDR_CAMERA_ANGLE_Y      			:= 0xB6F108
global ADDR_CAMERA_ANGLE_Z      			:= 0x00B6F248

CalcScreenCoords(Coords,Boolean:=False) {
	if(!checkHandles() || !isObject(Coords))
		return false
	
	dwM := 0xB6FA2C
	
	m_11 := readFloat(hGTA, dwM + 0*4)
	if(ErrorLevel) {
		ErrorLevel := ERROR_READ_MEMORY
		return false
	}
	
	m_12 := readFloat(hGTA, dwM + 1*4)
	m_13 := readFloat(hGTA, dwM + 2*4)
	m_21 := readFloat(hGTA, dwM + 4*4)
	m_22 := readFloat(hGTA, dwM + 5*4)
	m_23 := readFloat(hGTA, dwM + 6*4)
	m_31 := readFloat(hGTA, dwM + 8*4)
	m_32 := readFloat(hGTA, dwM + 9*4)
	m_33 := readFloat(hGTA, dwM + 10*4)
	m_41 := readFloat(hGTA, dwM + 12*4)
	m_42 := readFloat(hGTA, dwM + 13*4)
	m_43 := readFloat(hGTA, dwM + 14*4)
	
	dwLenX := readDWORD(hGTA, 0xC17044)
	if(ErrorLevel) {
		ErrorLevel := ERROR_READ_MEMORY
		return false
	}
	dwLenY := readDWORD(hGTA, 0xC17048)
	
	frX := Coords[3] * m_31 + Coords[2] * m_21 + Coords[1] * m_11 + m_41
	frY := Coords[3] * m_32 + Coords[2] * m_22 + Coords[1] * m_12 + m_42
	frZ := Coords[3] * m_33 + Coords[2] * m_23 + Coords[1] * m_13 + m_43
	
	fRecip := 1.0/frZ
	frX *= fRecip * dwLenX
	frY *= fRecip * dwLenY
    
    if(frX<=dwLenX && frY<=dwLenY && frZ>1){
		if(frX > 700 && frX < 800){
			return Boolean ? true : [frX,frY,frZ]
		}
	}	
}

GetCamPos(ByRef _PX,ByRef _PY){
    If(!checkHandles())
        return false
	_PX := (readFloat(hGTA, ADDR_CAMERA_POS_X))
	_PY := (readFloat(hGTA, ADDR_CAMERA_POS_Y))
	return
}

GetCamInfo()
{
    If(!checkHandles())
        return false

	AX := (readFloat(hGTA, ADDR_CAMERA_ANGLE_X)*(180/VAR_PI))?(-1):(AX<0)?(AX+=360):(AX)
	AY := (readFloat(hGTA, ADDR_CAMERA_ANGLE_Y)*(180/VAR_PI))?(-1):(AY<0)?(AY+=360):(AY)
	AZ := (readFloat(hGTA, ADDR_CAMERA_ANGLE_Z)*(180/VAR_PI))?(-1):(AZ<0)?(AZ+=360):(AZ)
	PX := (readFloat(hGTA, ADDR_CAMERA_POS_X))
	PY := (readFloat(hGTA, ADDR_CAMERA_POS_Y))

	return {AX:AX,AY:AY,AZ:AZ,PX:PX,PY:PY}
}

GetAngleX(){
	If(!checkHandles())
		return false
	return !(ANGLE := (readFloat(hGTA, ADDR_CAMERA_ANGLE_X)*(180/VAR_PI)))?(-1):(ANGLE<0)?(ANGLE:=ANGLE+360):(ANGLE)
}

GetCamAngleEX(Dim:="X",Flag:="D"){
	If(!checkHandles() || Flag != "D" || Flag != "R" || Dim != "X" || Dim != "Y" || Dim != "Z")
		return false
		
	if(Flag:="D")
		return !(ANGLE := (readFloat(hGTA, ADDR_CAMERA_ANGLE_ "" Dim)*(180/VAR_PI))?(-1):(ANGLE<0)?(ANGLE:=ANGLE+360):(ANGLE))
	else if(Flag:="R")
		return readFloat(hGTA, ADDR_CAMERA_ANGLE_ "" Dim)

}

GetAngleY(){
	If(!checkHandles())
		return false
	return !(ANGLE := (readFloat(hGTA, ADDR_CAMERA_ANGLE_Y)*(180/VAR_PI)))?(-1):(ANGLE<0)?(ANGLE:=ANGLE+360):(ANGLE)
}

GetAngleZ(){
	If(!checkHandles())
		return false
	return !(ANGLE := (readFloat(hGTA, ADDR_CAMERA_ANGLE_Z)*(180/VAR_PI)))?(-1):(ANGLE<0)?(ANGLE:=ANGLE+360):(ANGLE)
}

SetCameraAngleX(_PosX)
{
    If(!checkHandles())
        return false
	return writeMemory(hGTA,ADDR_CAMERA_CURR_X,(VAR_RADIANT*((_PosX<=180)?(_PosX-=360):(_PosX)))-(VAR_RADIANT*90),4,"float")
}

SetCameraAngleXByRad(_PosX)
{
    If(!checkHandles())
        return false
	return writeMemory(hGTA,ADDR_CAMERA_CURR_X,_Pox,4,"float")
}

GetAngleToMarker()
{
    If(!checkHandles() || !IsMarkerCreated())
        return false
	_MCoords := CoordsFromRedmarker()
	return atan2(_MCoords[2] - readFloat(hGTA, ADDR_CAMERA_POS_Y),_MCoords[1] - readFloat(hGTA, ADDR_CAMERA_POS_X))
}

atan2(x,y) {
   Return dllcall("msvcrt\atan2","Double",y, "Double",x, "CDECL Double")
}

*/