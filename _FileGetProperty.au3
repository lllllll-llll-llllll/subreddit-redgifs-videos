;===============================================================================
; Function Name.....: _FileGetProperty
; Description.......: Returns a property, or all properties, for a file.
; Version...........: 1.0.4
; Change Date.......: 09-03-2017
; AutoIt Version....: 3.3.14.x (due to the use of Static, but it could be a Global and use 3.2.12.x)
; Parameter(s)......: $FGP_Path - String containing the file path to return the property from.
;                     $FGP_PROPERTY - [optional] String containing the name of the property to return. (default = "")
;                     $iPropertyCount - [optional] The number of properties to search through for $FGP_PROPERTY, or the number of items
;                                       returned in the array if $FGP_PROPERTY is blank. (default = 500)
; Requirements(s)...: None
; Return Value(s)...: Success: Returns a string containing the property value.
;                     If $FGP_PROPERTY is blank, a two-dimensional array is returned:
;                         $av_array[0][0] = Number of properties.
;                         $av_array[1][0] = 1st property name.
;                         $as_array[1][1] = 1st property value.
;                         $av_array[n][0] = nth property name.
;                         $as_array[n][1] = nth property value.
;                     Failure: Returns an empty string and sets @error to:
;                       1 = The folder $FGP_Path does not exist.
;                       2 = The property $FGP_PROPERTY does not exist or the array could not be created.
;                       3 = Unable to create the "Shell.Application" object $objShell.
; Author(s).........: - Simucal <Simucal@gmail.com>
;                     - Modified by: Sean Hart <autoit@hartmail.ca>
;                     - Modified by: teh_hahn <sPiTsHiT@gmx.de>
;                     - Modified by: BrewManNH
;                     - Modified by: argumentum ; added some optimization, fixed Win10 issue
; URL...............: https://www.autoitscript.com/forum/topic/148232-_filegetproperty-retrieves-the-properties-of-a-file/?do=findComment&comment=1364968
; Note(s)...........: Modified the script that teh_hahn posted at the above link to include the properties that
;                     Vista and Win 7 include that Windows XP doesn't. Also removed the ReDims for the $av_ret array and
;                     replaced it with a single ReDim after it has found all the properties, this should speed things up.
;                     I further updated the code so there's a single point of return except for any errors encountered.
;                     $iPropertyCount is now a function parameter instead of being hardcoded in the function itself.
;                     Added the use of $FGP_PROPERTY as Index + 1 ( as is shown the array ), in additon to $FGP_PROPERTY as Verb
;                     Added the array Index to the @extended, as this the optimization is for just te last index used.
;                     Fixed array chop short on ReDim ( Win10 issue )
;===============================================================================
Func _FileGetProperty($FGP_Path, $FGP_PROPERTY = "", $iPropertyCount = 500)
    If $FGP_PROPERTY = Default Then $FGP_PROPERTY = ""
    $FGP_Path = StringRegExpReplace($FGP_Path, '["'']', "") ; strip the quotes, if any from the incoming string
    If Not FileExists($FGP_Path) Then Return SetError(1, 0, "") ; path not found
    Local Const $objShell = ObjCreate("Shell.Application")
    If @error Then Return SetError(3, 0, "")
    Local Const $FGP_File = StringTrimLeft($FGP_Path, StringInStr($FGP_Path, "\", 0, -1))
    Local Const $FGP_Dir = StringTrimRight($FGP_Path, StringLen($FGP_File) + 1)
    Local Const $objFolder = $objShell.NameSpace($FGP_Dir)
    Local Const $objFolderItem = $objFolder.Parsename($FGP_File)
    Local $Return = "", $iError = 0, $iExtended = 0
    Local Static $FGP_PROPERTY_Text = "", $FGP_PROPERTY_Index = 0
    If $FGP_PROPERTY_Text = $FGP_PROPERTY And $FGP_PROPERTY_Index Then
        If $objFolder.GetDetailsOf($objFolder.Items, $FGP_PROPERTY_Index) = $FGP_PROPERTY Then
            Return SetError(0, $FGP_PROPERTY_Index, $objFolder.GetDetailsOf($objFolderItem, $FGP_PROPERTY_Index))
        EndIf
    EndIf
    If Int($FGP_PROPERTY) Then
        $Return = $objFolder.GetDetailsOf($objFolderItem, $FGP_PROPERTY - 1)
        If $Return = "" Then
            $iError = 2
        EndIf
    ElseIf $FGP_PROPERTY Then
        For $I = 0 To $iPropertyCount
            If $objFolder.GetDetailsOf($objFolder.Items, $I) = $FGP_PROPERTY Then
                $FGP_PROPERTY_Text = $FGP_PROPERTY
                $FGP_PROPERTY_Index = $I
                $iExtended = $I
                $Return = $objFolder.GetDetailsOf($objFolderItem, $I)
            EndIf
        Next
        If $Return = "" Then
            $iError = 2
        EndIf
    Else
        Local $av_ret[$iPropertyCount + 1][2]
        For $I = 1 To $iPropertyCount
            If $objFolder.GetDetailsOf($objFolder.Items, $I) Then
                $av_ret[0][0] = $I
                $av_ret[$I][0] = $objFolder.GetDetailsOf($objFolder.Items, $I - 1)
                $av_ret[$I][1] = $objFolder.GetDetailsOf($objFolderItem, $I - 1)
            EndIf
        Next
        ReDim $av_ret[$av_ret[0][0] + 1][2]
        If Not $av_ret[1][0] Then
            $iError = 2
            $av_ret = $Return
        Else
            $Return = $av_ret
        EndIf
    EndIf
    Return SetError($iError, $iExtended, $Return)
EndFunc   ;==>_FileGetProperty
