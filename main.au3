#include <array.au3>
#include <file.au3>
#include <_VIDEO.au3>

$min_frames = 23
$max_frames = 1000
$min_length = 10
$max_length = 1000
$min_bitrate = 800
$max_bitrate = 15000


$subreddits = FileReadToArray('subreddits.txt')
$matches = ''
for $i = 0 to ubound($subreddits)-1
   $request = 'curl -o "json.txt" "https://www.reddit.com/r/' & $subreddits[$i] & '/hot/.json?limit=100&t=all&count=100" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0" -H "Accept: */*" -H "Accept-Language: en-US,en;q=0.5" -H "Referer: https://reddit.com" -H "Origin: https://reddit.com" -H "DNT: 1" -H "Connection: keep-alive" -H "TE: Trailers"'
   cmd($request)
   $json = FileReadline('json.txt')

   $regex = StringRegExp($json, '"url_overridden_by_dest": "https:\/\/redgifs\.com\/watch\/(.*?)"', 3)
   $matches &= _arraytostring($regex, ' ')

   sleep(200)
next
$matches = _arrayunique(stringsplit($matches, ' ', 3))
_arraydelete($matches, 0)

$log = FileReadToArray('downloaded.txt')
if ubound($log) > 0 then
   if ubound($matches) > 0 then
	  local $fresh[0]
	  for $i = 0 to ubound($matches)-1
		 $good = true
		 for $j = 0 to ubound($log)-1
			if $matches[$i] = $log[$j] then
			   $good = false
			endif
		 next

		 if $good then
			_arrayadd($fresh, $matches[$i])
		 endif
	  next
	  $matches = $fresh
   endif
endif

for $i = 0 to ubound($matches)-1
   $url = 'https://redgifs.com/watch/' & $matches[$i]
   inetget($url, 'html.txt')
   $lines = FileReadLine('html.txt', 1) & FileReadLine('html.txt', 2) & FileReadLine('html.txt', 3) & FileReadLine('html.txt', 4)
   $regex = stringregexp($lines, 'https://thumbs2.redgifs.com/(.*?)[.-]', 3)
   for $j = 0 to ubound($regex)-1
	  $first_character = stringleft($regex[$j], 1)
	  if (stringisupper($first_character)) then
		 $matches[$i] = $regex[$j]
		 exitloop
	  endif
   next

   FileDelete('html.txt')
next

for $i = 0 to ubound($matches)-1
   $id = $matches[$i]
   $url = 'https://thumbs2.redgifs.com/' & $id & '.mp4'
   $filename = @scriptdir & '\videos\' & $id & ' .mp4'
   $request = 'curl -o "' & $filename & '" "' & $url & '" -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8" -H "Accept-Language: en-US,en;q=0.5" -H "Referer: https://www.redgifs.com/" -H "DNT: 1" -H "Connection: keep-alive" -H "Upgrade-Insecure-Requests: 1" -H "Pragma: no-cache" -H "Cache-Control: no-cache" -H "TE: Trailers"'
   cmd($request)

   filter($filename)
   filewriteline('downloaded.txt', $id)
   sleep(100)
next


func filter($p)
   $frames = stringtrimleft(_FileGetFPS($p, 'Frame rate'),	1)
   $rate   = stringtrimleft(_FileGetFPS($p, 'Data rate'),	1)
   $length = _FileGetFPS($p, 'Length')

   if ($frames < $min_frames) or ($frames = -1) or ($frames > $max_frames) then
	  FileDelete($p)

   elseif ($rate < $min_bitrate) or ($rate > $max_bitrate) or ($rate = -1) then
	  FileDelete($p)

   elseif ($length < $min_length) or ($length = -1) or ($length > $max_length) then
	  FileDelete($p)

   endif

endfunc





func cmd($command)
   runwait(@ComSpec & " /c " & $command, "", @SW_HIDE)
endfunc




