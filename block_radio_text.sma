/*
 * Block Radio Text
 * Copyright (c) 2017 Alik Aslanyan <cplusplus256@gmail.com>
 *
 *
 *
 *    This program is free software; you can redistribute it and/or modify it
 *    under the terms of the GNU General Public License as published by the
 *    Free Software Foundation; either version 2 of the License, or (at
 *    your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful, but
 *    WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software Foundation,
 *    Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

#include <amxmodx>

#define PROFILE

#if defined PROFILE
	#include <easy_profiler>
#endif

#define PLUGIN "Block Radio Text"
#define VERSION "1.0"
#define AUTHOR "Inline"

new Trie:g_searchDictionary = Invalid_Trie;
public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	register_message(get_user_msgid("TextMsg"), "mBlockRadioMessage");

#if defined PROFILE
	ep_calibrate(2);
#endif

	InitTrie();
}

public plugin_end()
{
	TrieDestroy(g_searchDictionary);
}

InitTrie()
{
#if defined PROFILE
	ep_start();
#endif

	g_searchDictionary = TrieCreate();

	/*by ConnorMcLead*/
	new const radioMessages[][] =
	{
		"#Cover_me", 
		"#You_take_the_point", 
		"#Hold_this_position",
		"#Regroup_team",
		"#Follow_me",
		"#Taking_fire",
		"#Go_go_go", 
		"#Team_fall_back",
		"#Stick_together_team",
		"#Get_in_position_and_wait",
		"#Storm_the_front",
		"#Report_in_team",
		"#Roger_that",
		"#Affirmative",
		"#Enemy_spotted",
		"#Need_backup", 
		"#Sector_clear", 
		"#In_position",
		"#Reporting_in", 
		"#Get_out_of_there", 
		"#Negative", 
		"#Enemy_down"
	};
	
	for(new i = 0; i < sizeof(radioMessages); ++i)
	{
		TrieSetCell(g_searchDictionary, radioMessages[i], 1);
	}
	
#if defined PROFILE
	ep_end(1, "InitTrie(): executed in %.17f seconds");
#endif
}

public mBlockRadioMessage(msgID, dest, receiver)
{

	if(get_msg_arg_int(1) != 5)
		return PLUGIN_CONTINUE;
	

	static subMessage[64];
	get_msg_arg_string(5, subMessage, charsmax(subMessage));
#if defined PROFILE
	ep_start();
#endif
	if(subMessage[0] == '#' && TrieKeyExists(g_searchDictionary, subMessage))
	{
#if defined PROFILE
	ep_end(1, "mBlockRadioMessage(): found, %.17f seconds");
#endif
		return PLUGIN_HANDLED;
	}
	
#if defined PROFILE
	ep_end(1, "mBlockRadioMessage(): not found, %.17f seconds");
#endif
	return PLUGIN_CONTINUE;
}

