quick autoit script for scraping redgif videos from specified subreddits
will delete downloaded videos based on specified min/max frames per second, length in seconds, or video data rate in kbps
download log prevents redownloading videos

process:
- place "_VIDEO.au3" and "_FileGetProperty.au3" into autoit "AutoIt3\Include\" directory
- create "subreddits.txt" in the same directory as "main.au3"
- add subreddit names (not urls) one per line into "subreddits.txt"
- run "main.au3"
- a "\videos\" folder will be created in the same directory as "main.au3" and videos will be downloaded here
- a "downloaded.txt" file will be created in the same directory as "main.au3" and videos that are downloaded will have their redgifs id logged here to prevent redownloads
- videos that are downloaded are filtered according to settings. if they fail something they are deleted.


things to improve:
- prevent duplicate entries in "downloads.txt"
- check video stream metadata BEFORE downloading (perhaps via ffprobe)
- 
