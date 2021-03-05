#include <_FileGetProperty.au3>

Func _FileGetFPS($fullpath, $property)
   $prop = _FileGetProperty($fullpath, $property)
   if $prop = '' then return -1

   if $property = 'Frame rate' then
	  $string = stringsplit($prop, '.', 2)
	  return $string[0]

   elseif $property = 'Data rate' then
	  $string = stringtrimright($prop, 4)
	  return $string

   elseif $property = 'Length' then
	  $prop  = stringsplit($prop, ':', 3)
	  $hours = $prop[0]
	  $mins  = $prop[1]
	  $secs  = $prop[2]
	  $totalsecs = $secs + ($mins * 60) + ($hours * 60*60)
	  return $totalsecs

   endif

   return -1

endfunc
