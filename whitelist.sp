#include <sourcemod>
#include <dbi>

public Plugin myinfo =
{
	name		= "AXE KZ Whitelist",
	author		= "Reeed",
	description = "Whitelist plugin for AXE KZ servers",
	version		= "0.1",
	url			= "https://axekz.com"
};

Database hDatabase = null;

public void OnPluginStart()
{
	StartSQL();
}

public void OnClientAuthorized(int client)
{
	// PrintToServer("authorized?");
	char auth[255];
	GetClientAuthId(client, AuthId_Steam2, auth, sizeof(auth));
	CheckWhitelist(client, auth);
}

void StartSQL()
{
	Database.Connect(GotDatabase, "firstjoin");
}

public void GotDatabase(Database db, const char[] error, any data)
{
	if (db == null)
	{
		PrintToServer("Database failure: %s", error);
	}
	else
	{
		hDatabase = db;
	}
}

void CheckWhitelist(int client, const char[] auth)
{
	char query[255];
	FormatEx(query, sizeof(query), "SELECT whitelist FROM firstjoin WHERE auth = '%s'", auth);
	hDatabase.Query(T_CheckWhitelist, query, GetClientUserId(client));
}

public void T_CheckWhitelist(Database db, DBResultSet results, const char[] error, any data)
{
	int client = 0;
	if ((client = GetClientOfUserId(data)) == 0)
	{
		return;
	}

	if (db == null || results == null || error[0] != '\0')
	{
		PrintToServer("Authorization error: %s", error);
		KickClient(client, "身份验证出错");
	}
	else
	{
		if (results.FetchRow() && results.FetchInt(0) == 0)
		{
			KickClient(client, "你未在服务器白名单中, 请访问网站axekz.com获取白名单")
		}
	}
}
