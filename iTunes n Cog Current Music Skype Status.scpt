tell application "Skype"
	activate
	set status to the send command "GET PROFILE MOOD_TEXT" script name "CogCurrentMusicSkypeStatus"
	-- set status to «event sendskyp» given «class cmnd»:"GET USERSTATUS", «class scrp»:"This Script" -- Command can be any Skype API command
	(*
"COMMAND_PENDING" is returned when a Skype API command is issued but not yet accepted. 
The reason it may not be accepted is likely because the application that sent the command has not been configured as a Skype API Client. 
If Skype gets an API command from an application that has not been configured as a Skype API client, then the "Skype API Security" pop up appears instantly. 
So we'll check to see if that is indeed the case and if it is, we'll add Applescript as an API Client and close the pop up.
*)
	if status is "COMMAND_PENDING" then
		tell application "System Events" to tell process "Skype"
			if window "Skype API Security" exists then
				click radio button "Allow this application to use Skype" of radio group 1 of window "Skype API Security"
				delay 1
				click button "OK" of window "Skype API Security"
			end if
		end tell
		delay 15 -- Optional delay to allow skype to finish connecting
	end if
end tell



set track_info to the ""
set old_track_info to the ""
set track_info_announcement to the ""

set music_str_start_marker to the "[Music]:"
set skype_mood_text_starter to the "PROFILE MOOD_TEXT "
set skype_mood_text_starter2 to the "COMMAND_PENDING "

repeat
	set update_required to false
	set current_mood_messaage to the ""
	tell application "System Events"
		if exists process "Skype" then
			tell application "Skype"
				set current_mood_messaage to the send command "GET PROFILE MOOD_TEXT" script name "CogCurrentMusicSkypeStatus"
				
				--set current_mood_messaage to the «event sendskyp» given «class cmnd»:"GET PROFILE MOOD_TEXT", «class scrp»:"CogCurrentMusicSkypeStatus"
				
				if current_mood_messaage is equal to skype_mood_text_starter then
					set current_mood_messaage to the ""
				else if current_mood_messaage starts with skype_mood_text_starter then
					set current_mood_messaage to the text ((length of skype_mood_text_starter) + 1) thru -1 of current_mood_messaage
				end if
				
				if current_mood_messaage is equal to skype_mood_text_starter2 then
					set current_mood_messaage to the ""
				else if current_mood_messaage starts with skype_mood_text_starter2 then
					set current_mood_messaage to the text ((length of skype_mood_text_starter2) + 1) thru -1 of current_mood_messaage
				end if
				
				if current_mood_messaage contains music_str_start_marker then
					set marker_offset to the offset of music_str_start_marker in current_mood_messaage
					if (marker_offset = 1) then
						set current_mood_messaage to the ""
					else
						set current_mood_messaage to the text 1 thru (marker_offset - 1) of current_mood_messaage
					end if
				else
					set update_required to true
				end if
				
				-- trim spaces
				repeat until current_mood_messaage does not start with " "
					set current_mood_messaage to text 2 thru -1 of current_mood_messaage
				end repeat
				
				repeat until current_mood_messaage does not end with " "
					set current_mood_messaage to text 1 thru -2 of current_mood_messaage
				end repeat
				
			end tell
		end if
	end tell
	
	set track_info to ""
	set track_info_announcement to the ""
	tell application "System Events"
		if exists process "iTunes" then
			tell application "iTunes"
				(* Grab info only if iTunes is playing *)
				if player state is playing then
					if class of current track is URL track then
						set radio_title to name of current track
						set track_title to current stream title
						set track_info to the current_mood_messaage & " " & music_str_start_marker & " " & track_title & " (Streaming from '" & radio_title & "')"
						set track_info_announcement to the "Now playing: " & track_title & " streamed from " & radio_title
					else
						set this_title to name of current track
						set this_artist to artist of current track
						set this_album to album of current track
						set this_year to year of current track
						set track_info to the current_mood_messaage & " " & music_str_start_marker & " " & this_artist & " - " & this_title & " (\"" & this_album & "\" '" & this_year & ")"
						set track_info_announcement to the "Now playing: track " & this_title & " by " & this_artist
						if not (this_album = "") then
							set track_info_announcement to the track_info_announcement & " from album " & this_album
						end if
						if not (this_year = "") then
							set track_info_announcement to the track_info_announcement & " - year " & this_year
						end if
					end if
				end if
			end tell
		end if
	end tell
	
	if (track_info = "") then
		tell application "System Events"
			if (exists process "Cog") then
				tell application "Cog"
					if (exists title of currententry) then
						set this_title to the title of currententry
						set this_artist to the artist of currententry
						set this_album to the album of currententry
						set this_year to the year of currententry
						set track_info to the current_mood_messaage & " " & music_str_start_marker & " " & this_artist & " - " & this_title & " (\"" & this_album & "\" '" & this_year & ")"
						set track_info_announcement to the "Now playing: track " & this_title & " by " & this_artist
						if not (this_album = "") then
							set track_info_announcement to the track_info_announcement & " from album " & this_album
						end if
						if not (this_year = "") then
							set track_info_announcement to the track_info_announcement & " - year " & this_year
						end if
					end if
				end tell
			end if
		end tell
	end if
	
	if (track_info = "") then
		set track_info to the current_mood_messaage
	end if
	
	if (not track_info = old_track_info or update_required) then
		set old_track_info to the track_info
		-- say track_info_announcement
		tell application "System Events"
			if exists process "Skype" then
				tell application "Skype"
					send command "SET PROFILE MOOD_TEXT " & track_info script name "CogCurrentMusicSkypeStatus"
					--«event sendskyp» given «class cmnd»:"SET PROFILE MOOD_TEXT " & track_info, «class scrp»:"CogCurrentMusicSkypeStatus"
				end tell
			end if
		end tell
	end if
	delay 15
	
end repeat

