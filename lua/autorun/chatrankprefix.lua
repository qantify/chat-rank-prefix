--[[
--
-- // Chat Rank Prefix //
--
-- Prefix chat messages with the user's team.
--
-- MIT License
--
-- Copyright (c) 2019 Qantify
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the 'Software'), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
--]]

// Settings variables defined in a table.
local convars = {
	showDead = {"chatrankprefix_showdead", "1", FCVAR_REPLICATED, "Show the *DEAD* text?"},
	showRank = {"chatrankprefix_showrank", "1", FCVAR_REPLICATED, "Show teams?"},
	useTeamColor = {"chatrankprefix_userankcolor", "1", FCVAR_REPLICATED, "Use team colors for the player name?"},
	enabled = {"chatrankprefix_enabled", "1", FCVAR_REPLICATED, "Enable chat rank prefixes?"}
}

// If this is running serverside:
if SERVER then
	// Add this file to the client downloads.
	AddCSLuaFile()
	// Create convars.
	for _, convar in pairs(convars) do
		CreateConVar(unpack(convar))
	end
	// Prevent this script from running further.
	return
end

// Chat message colors.
local clr = {
	white = Color(255, 255, 255),
	dead = Color(255, 24, 35),
	team = Color(24, 162, 35)
}

// Function to convert settings convars into booleans.
local function getSettings()
	// Table to contain values.
	local values = {}
	// Loop and get boolean values.
	for name, convar in pairs(convars) do
		values[name] = GetConVar(convar[1]):GetBool() // TODO: This is inefficient, cache convar objects.
	end
	// Return the created table.
	return values
end

// Run this function every time a player sends a message.
hook.Add("OnPlayerChat", "OnPlayerChatRankPrefix", function(ply, text, isTeam, isDead)
	// Get settings.
	local settings = getSettings()

	// Don't do anything if disabled.
	if not settings.enabled then return end

	// Get the player's team.
	local teamID = ply:Team()

	// Define a table to hold the current message structure.
	local msg = {}

	// Simple function to quickly add to the message.
	local function insert(value)
		msg[#msg + 1] = value
	end

	// Fill in message.
	if settings.showDead and isDead then
		insert(clr.dead)
		insert("*DEAD* ")
	end
	if isTeam then
		insert(clr.team)
		insert("(TEAM) ")
	end
	if settings.showRank then
		insert(team.GetColor(teamID))
		insert("[")
		insert(team.GetName(teamID))
		insert("] ")
	end
	if settings.useTeamColor then
		insert(team.GetColor(teamID))
	else
		insert(ply:GetColor())
	end
	insert(ply:Name())
	insert(clr.white)
	insert(": ")
	insert(text)

	// Display the message on-screen.
	chat.AddText(unpack(msg))

	// Do not print the message normally.
	return true
end)
