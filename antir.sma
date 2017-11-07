#include <amxmodx>

#define RETRY_ON_KICK
#define ReAPI

#if defined ReAPI
	#include <reapi>
	#define IGNORE_CALL HC_CONTINUE
	#define BLOCK_CALL HC_BREAK
#else
	#include <fakemeta>
	#include <orpheu>
	#define IGNORE_CALL _:OrpheuIgnored
	#define BLOCK_CALL _:OrpheuSupercede
#endif


#if !defined ReAPI
new g_ClientPtr;
new g_ElementSize;
new g_EntityOffset;
#endif
new g_PlayerWarns[33];

enum CVAR
{
	CVAR_MAX_WARNS,
	CVAR_RESET_TIME
};

new g_Cvars[CVAR] = {0, };

#if !defined ReAPI
new g_DisconnectForward;
#endif

#pragma semicolon 1

public plugin_init()
{
#if defined ReAPI
	register_plugin("[ReAPI] Anti overflow", "3.1", "mazdan & Inline, WPMGPRoSToTeMa");
#else
	register_plugin("Anti overflow", "3.1", "mazdan & Inline, WPMGPRoSToTeMa");
#endif	

	g_Cvars[CVAR_MAX_WARNS] = register_cvar("antir_max_warns", "5");
	g_Cvars[CVAR_RESET_TIME] = register_cvar("antir_reset_time", "10");

#if defined ReAPI
	RegisterHookChain(RH_SV_DropClient, "SV_DropClient", false); 
#else
	OrpheuRegisterHook( OrpheuGetFunction("SV_DropClient"), "SV_DropClient",OrpheuHookPre);	
	g_DisconnectForward = register_forward(FM_ClientDisconnect, "ClientDisconnect");
#endif	


}
#if defined ReAPI
public SV_DropClient( id , crash , const message[] )
#else
public OrpheuHookReturn:SV_DropClient( clientPtr , crash , const message[] ) 
#endif
{	
	new ret = IGNORE_CALL;
#if !defined ReAPI	
	if(g_ElementSize && g_EntityOffset)
#endif
	{

		if(containi(message, "Reliable channel overflowed") != -1)
		{
#if !defined ReAPI
			new id = (clientPtr - g_EntityOffset) / g_ElementSize;
#endif
			if(g_PlayerWarns[id]++ < get_pcvar_num(g_Cvars[CVAR_MAX_WARNS]))
			{
				if(task_exists(id))
					remove_task(id);
					
				set_task(get_pcvar_float(g_Cvars[CVAR_RESET_TIME]), "Task_ResetWarns", id);
				
				ret = BLOCK_CALL;
			}
			else
			{
#if defined RETRY_ON_KICK
				client_cmd(id, "retry");
#endif
				ret = IGNORE_CALL;
			}
		}
	}
#if !defined ReAPI		
	else
	{
		if(containi(message, "Reliable channel overflowed") != -1)
		{
			ret = BLOCK_CALL;
		}
		g_ClientPtr = clientPtr;
	}
#endif

#if defined ReAPI	
	return ret;
#else
	return OrpheuHookReturn:ret;
#endif
}

public Task_ResetWarns(id)
	g_PlayerWarns[id] = 0;

public client_connect(id)
	g_PlayerWarns[id] = 0;

#if !defined ReAPI	
public ClientDisconnect(id) // After SV_DropClient
{
	static entityId = 0, lastPointer = 0;
	
	if(g_ClientPtr)
	{
		if(entityId && entityId != id)
		{
			g_ElementSize = abs( (g_ClientPtr - lastPointer) / (id - entityId) );
			g_EntityOffset = abs( g_ClientPtr - (id * g_ElementSize) );
			
			unregister_forward(FM_ClientDisconnect, g_DisconnectForward);
		}
		else
		{
			lastPointer = g_ClientPtr;
			entityId = id;
		}
	}
}
#endif
