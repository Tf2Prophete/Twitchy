#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Imgs\Icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=1.2.0.0
#AutoIt3Wrapper_Res_LegalCopyright=R.S.S.
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
; *** End added by AutoIt3Wrapper ***
;~ #AutoIt3Wrapper_Icon=Images\Icon.ico

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <TrayConstants.au3>



#include ".\Skins\Axis.au3"
#include "_UskinLibrary.au3"

_Uskin_LoadDLL()
_USkin_Init(_Axis(True))

Opt("GUIOnEventMode", 1)
Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)

Global $MainGui, $ProfileGui

Global $CurrentProfileDisplay, $ProfileData, $KeyListing, $ReadProfileData, $ReadProfileName, $NewKeyData = ""

Dim $Keys[11] = ["Default", "{NUMPAD0}", "{NUMPAD1}", "{NUMPAD2}", "{NUMPAD3}", "{NUMPAD4}", "{NUMPAD5}", "{NUMPAD6}", _
		"{NUMPAD7}", "{NUMPAD8}", "{NUMPAD9}"]


$TrayMenuExit = TrayCreateItem("Exit...")
TrayItemSetOnEvent(-1, "_Exit")
$TrayMenuOptions = TrayCreateMenu("Options...")
$TrayMenuOptionsStateItem = TrayCreateItem("Enabled", $TrayMenuOptions)
TrayItemSetOnEvent(-1, "_CheckState")
$TrayMenuOptionsGUIItem = TrayCreateItem("Show GUI...", $TrayMenuOptions)
TrayItemSetOnEvent(-1, "_ShowGui")

$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
If $ReadState = "1" Then
	TrayItemSetState($TrayMenuOptionsStateItem, $TRAY_CHECKED)
Else
	TrayItemSetState($TrayMenuOptionsStateItem, $TRAY_UNCHECKED)
	_UnAssignHotKeys()
EndIf

$ReadProfileName = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "1", "Default")
If $ReadProfileName = "Default" Then
	Sleep(10)
Else
	$CurrentProfile = $ReadProfileName
	GUICtrlSetData($CurrentProfileDisplay, $CurrentProfile)
	_AssignHotKeys()
EndIf

Func _CheckState()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		IniWrite(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "1")
		TrayItemSetState($TrayMenuOptionsStateItem, $TRAY_CHECKED)
		_AssignHotKeys()
	Else
		IniWrite(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "0")
		TrayItemSetState($TrayMenuOptionsStateItem, $TRAY_UNCHECKED)
		_UnAssignHotKeys()
	EndIf
EndFunc   ;==>_CheckState


Func _ShowGui()
	$MainGui = GUICreate("Twitchy", 400, 165)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseMainGui")

	GUICtrlCreateLabel("Current Profile", 140, 10, 300, 50)
	GUICtrlSetFont(-1, 14)

	$CurrentProfileDisplay = GUICtrlCreateInput("", 10, 50, 380, 30, BitOR($ES_CENTER, $ES_READONLY))
	GUICtrlSetFont(-1, 15)
	GUICtrlSetColor(-1, 0xB40404)

	$ChangeProfilesButton = GUICtrlCreateButton("Change Profiles", 20, 100, 150, 40)
	GUICtrlSetFont(-1, 15)
	GUICtrlSetOnEvent(-1, "_ChangeProfileGui")


	$EditProfileButton = GUICtrlCreateButton("Edit Profile", 230, 100, 150, 40)
	GUICtrlSetFont(-1, 15)
	GUICtrlSetOnEvent(-1, "_EditProfileGui")

	GUICtrlCreateLabel("© TF2Prophete", 170, 152, 200, 50)
	GUICtrlSetFont(-1, 7)

	$ReadProfileName = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "1", "Default")
	If $ReadProfileName = "Default" Then
		Sleep(10)
	Else
		$CurrentProfile = $ReadProfileName
		GUICtrlSetData($CurrentProfileDisplay, $CurrentProfile)
		_AssignHotKeys()
	EndIf


	GUISetState()
EndFunc   ;==>_ShowGui

Func _EditProfileGui()

	$ReadProfileName = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "1", "Default")
	If $ReadProfileName = "Default" Then
		MsgBox(48, "Error", "No profile loaded, please load a profile or create a new profile first!")
	Else

		GUISetState(@SW_DISABLE, $MainGui)

		$ProfileGui = GUICreate("Twitchy Profiles", 400, 165)
		GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseProfileGui")

		GUICtrlCreateLabel("Key List", 160, 10, 300, 50)
		GUICtrlSetFont(-1, 14)

		$KeyListing = GUICtrlCreateCombo("", 10, 40, 380, 30)
		GUICtrlSetFont(-1, 15)


		$ReadProfileData = IniReadSection(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile")
		For $i = 2 To $ReadProfileData[0][0]
			$ProfileData = $ReadProfileData[$i][0] & "|"
			GUICtrlSetData($KeyListing, $ProfileData)
		Next


		$ViewCurrentKey = GUICtrlCreateButton("View Key Binding", 10, 120, 180, 40)
		GUICtrlSetFont(-1, 14)
		GUICtrlSetOnEvent(-1, "_ViewKeyBinding")

		$EditCurrentKey = GUICtrlCreateButton("Edit Key Binding", 210, 120, 180, 40)
		GUICtrlSetFont(-1, 14)
		GUICtrlSetOnEvent(-1, "_EditKeyBinding")

		GUISetState()
	EndIf
EndFunc   ;==>_EditProfileGui

Func _EditKeyBinding()
	$NewKeyData = ""
	$Msg = GUICtrlRead($KeyListing)
	If $Msg = "" Then
		MsgBox(48, "Error", "No key selected, please select a key first!")
	Else

		While $NewKeyData = ""
			$NewKeyData = InputBox("Twitchy", "What would you like to assign to this key?" & @CRLF & @CRLF & "Please note, some special characters such as ! and some others will not work!")
			If $NewKeyData = "" Then
				MsgBox(48, "Error", "No data entered, exiting key binding!")
				$NewKeyData = "0"
			Else
				IniWrite(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", $Msg, $NewKeyData)
			EndIf
		WEnd
	EndIf
EndFunc   ;==>_EditKeyBinding

Func _ViewKeyBinding()
	$Msg = GUICtrlRead($KeyListing)
	If $Msg = "" Then
		MsgBox(48, "Error", "No key selected, please select a key first!")
	Else


		$KeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", $Msg, "Default")

		MsgBox(0, "Twitchy", $KeyData)

	EndIf
EndFunc   ;==>_ViewKeyBinding



Func _ChangeProfileGui()
	GUISetState(@SW_DISABLE, $MainGui)

	$ProfileGui = GUICreate("Twitchy Profiles", 400, 165)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_CloseGui")

	GUICtrlCreateLabel("Profile List", 140, 10, 300, 50)
	GUICtrlSetFont(-1, 14)

	$ProfileListing = GUICtrlCreateCombo("", 10, 40, 380, 30)
	GUICtrlSetFont(-1, 15)

	$GetProfilesCount = _FileListToArray(@ScriptDir & "/Data/Profiles/", Default, 2)
	If @error Then
		Sleep(10)
	Else

		Local $CurrentProfileList = ""

		For $i = 1 To $GetProfilesCount[0]
			$CurrentProfileList = $CurrentProfileList & $GetProfilesCount[$i] & "|"
		Next

		GUICtrlSetData($ProfileListing, $CurrentProfileList)

	EndIf

	$NewProfileButton = GUICtrlCreateButton("New Profile", 5, 120, 120, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_CreateNewProfile")

	$EditProfileButton = GUICtrlCreateButton("Load Profile", 140, 120, 120, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_LoadProfile")

	$DeleteProfileButton = GUICtrlCreateButton("Delete Profile", 275, 120, 120, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_RemoveProfile")

	GUISetState()
EndFunc   ;==>_ChangeProfileGui


Func _RemoveProfile()
	$GetDir = ""
	$CheckCancel = MsgBox(4, "Remove Profile...", "Are you sure you want to remove a profile?")
	If $CheckCancel = 6 Then
		While $GetDir = ""
			$GetDir = FileSelectFolder("Remove Profile...", @ScriptDir & "\Data\Profiles")
			If $GetDir = "" Then
				MsgBox(64, "Error", "No profile selected!")
				$GetDir = 1
			Else
				$CheckCancel = MsgBox(4, "Remove Profile...", "Are you sure you wish to remove this profile?")
				If $CheckCancel = 6 Then
					DirRemove($GetDir, 1)
					MsgBox(0, "Remove Profile...", "Profile removed!")
					GUIDelete($ProfileGui)
					_ChangeProfileGui()
				Else
					Sleep(10)
				EndIf
			EndIf
		WEnd
	Else
		Sleep(10)
	EndIf
EndFunc   ;==>_RemoveProfile

Func _LoadProfile()
	GUISetState(@SW_DISABLE, $ProfileGui)

	$ProfileToLoad = FileOpenDialog("Load Profile...", @ScriptDir & "\Data\Profiles", "Ini Files (*.ini)")
	If $ProfileToLoad = "" Then
		MsgBox(48, "Error", "No profile loaded!")
		GUISetState(@SW_ENABLE, $ProfileGui)
		WinActivate($ProfileGui)
	Else
		$Split = StringSplit($ProfileToLoad, "\")
		$DataToPull = $Split[0]
		$ProfileLoaded = $Split[$DataToPull]
		$ProfileLoaded = StringTrimRight($ProfileLoaded, 4)
		$CurrentProfile = $ProfileLoaded
		GUICtrlSetData($CurrentProfileDisplay, $ProfileLoaded)
		MsgBox(0, "Load Profile...", "Profile loaded!")
		IniWrite(@ScriptDir & "\Data\Settings.ini", "Settings", "1", $ProfileLoaded)
		GUISetState(@SW_ENABLE, $ProfileGui)
		WinActivate($ProfileGui)
		_AssignHotKeys()
	EndIf
EndFunc   ;==>_LoadProfile

Func _CreateNewProfile()
	$CheckName = ""
	GUISetState(@SW_DISABLE, $ProfileGui)

	$CheckCancel = MsgBox(4, "Create Profile...", "Are you ready to create a new profile?")
	If $CheckCancel = 6 Then
		While $CheckName = ""
			$CheckName = InputBox("New Profile...", "What would you like to name this new profile?")
			DirGetSize(@ScriptDir & "/Data/Profiles/" & $CheckName)
			If @error Then
				DirCreate(@ScriptDir & "/Data/Profiles/" & $CheckName)
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "Name", $CheckName)
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "0", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "1", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "2", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "3", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "4", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "5", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "6", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "7", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "8", "")
				IniWrite(@ScriptDir & "/Data/Profiles/" & $CheckName & "/" & $CheckName & ".ini", "Profile", "9", "")
				MsgBox(0, "New Profile...", "Profile created!")
				IniWrite(@ScriptDir & "\Data\Settings.ini", "Settings", "1", $CheckName)
				$CurrentProfile = $CheckName
				GUICtrlSetData($CurrentProfileDisplay, $CurrentProfile)
				GUIDelete($ProfileGui)
				_ChangeProfileGui()
				_AssignHotKeys()
			Else
				MsgBox(48, "Error", "A profile already exists with this name!")
				$CheckCancel = MsgBox(4, "Create Profile...", "Would you like to try again?")
				If $CheckCancel = 6 Then
					$CheckName = ""
				Else
					GUISetState(@SW_ENABLE, $ProfileGui)
					WinActivate($ProfileGui)
				EndIf
			EndIf
		WEnd
	Else
		Sleep(10)
		GUISetState(@SW_ENABLE, $ProfileGui)
		WinActivate($ProfileGui)
	EndIf

EndFunc   ;==>_CreateNewProfile

Func _UnAssignHotKeys()
	HotKeySet("{NUMPAD0}")
	HotKeySet("{NUMPAD1}")
	HotKeySet("{NUMPAD2}")
	HotKeySet("{NUMPAD3}")
	HotKeySet("{NUMPAD4}")
	HotKeySet("{NUMPAD5}")
	HotKeySet("{NUMPAD6}")
	HotKeySet("{NUMPAD7}")
	HotKeySet("{NUMPAD8}")
	HotKeySet("{NUMPAD9}")
EndFunc   ;==>_UnAssignHotKeys


Func _AssignHotKeys()

	HotKeySet("{NUMPAD0}")
	HotKeySet("{NUMPAD1}")
	HotKeySet("{NUMPAD2}")
	HotKeySet("{NUMPAD3}")
	HotKeySet("{NUMPAD4}")
	HotKeySet("{NUMPAD5}")
	HotKeySet("{NUMPAD6}")
	HotKeySet("{NUMPAD7}")
	HotKeySet("{NUMPAD8}")
	HotKeySet("{NUMPAD9}")

	$ReadProfileName = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "1", "Default")
	$ReadProfileData = IniReadSection(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile")
	Local $Count = 1
	For $i = 2 To $ReadProfileData[0][0]
		HotKeySet($Keys[$Count], "_SendKeyBinding" & $Count)
		$Count += 1
	Next

EndFunc   ;==>_AssignHotKeys

Func _SendKeyBinding1()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "0", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding1

Func _SendKeyBinding2()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "1", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding2

Func _SendKeyBinding3()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "2", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding3

Func _SendKeyBinding4()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "3", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding4

Func _SendKeyBinding5()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "4", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding5

Func _SendKeyBinding6()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "5", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding6

Func _SendKeyBinding7()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "6", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding7

Func _SendKeyBinding8()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "7", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding8

Func _SendKeyBinding9()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "8", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding9

Func _SendKeyBinding10()
	$ReadState = IniRead(@ScriptDir & "/Data/Settings.ini", "Settings", "2", "Default")
	If $ReadState = "0" Then
		Sleep(10)
	Else
		$ReadHotKeyData = IniRead(@ScriptDir & "/Data/Profiles/" & $ReadProfileName & "/" & $ReadProfileName & ".ini", "Profile", "9", "Default")
		Send($ReadHotKeyData)
	EndIf
EndFunc   ;==>_SendKeyBinding10



Func _CloseGui()
	GUIDelete($ProfileGui)
	GUISetState(@SW_ENABLE, $MainGui)
	WinActivate($MainGui)
EndFunc   ;==>_CloseGui

Func _CloseProfileGui()
	GUIDelete($ProfileGui)
	GUISetState(@SW_ENABLE, $MainGui)
	WinActivate($MainGui)
EndFunc   ;==>_CloseProfileGui

Func _CloseMainGui()
	GUIDelete($MainGui)
EndFunc   ;==>_CloseMainGui



Func _Exit()
	Exit
EndFunc   ;==>_Exit

While 1
	Sleep(10)
WEnd


