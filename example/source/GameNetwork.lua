
--[[--

Game Network allows access to 3rd party libraries that enables social gaming features
such as public leaderboards and achievements.

Currently, the OpenFeint and Game Center (iOS only) libraries are supported.

If you want to use both OpenFeint and Game Center, iOS OpenFeint will post achievement
updates and leaderboard updates to Game Center provided OFGameCenter.plist is present
in the project folder.

See http://support.openfeint.com/dev/game-center-compatibility/ for details.

@module qeeplay.api.GameNetwork

]]

local M = {}

local provider = __QEEPLAY_GLOBALS__["api.GameNetwork"]

--[[--

Initializes an app with the parameters (e.g., product key, secret, display name, etc.)
required by the game network provider.

**Syntax:**

    -- OpenFeint
    qeeplay.api.GameNetwork.init("openfeint", {
        productKey  = ...,
        secret      = ...,
        displayName = ...,
    })

    -- GameCenter
    qeeplay.api.GameNetwork.init("gamecenter", {
        listener = ...
    })

**Example:**

    require("qeeplay.api.GameNetwork")
    qeeplay.api.GameNetwork.init("openfeint", {
        productKey  = ...,
        secret      = ...,
        displayName = ...
    })

    --
    local achievements = qeeplay.api.GameNetwork.request("getAchievements")
    ccdump(achievements, "All achievements")

    local leaderboards = qeeplay.api.GameNetwork.request("getLeaderboards")
    ccdump(leaderboards, "All leaderboards")

    local score = math.random(100, 200)
    local displayText = string.format("My score is %d", score)
    qeeplay.api.GameNetwork.request("setHighScore", "916960912", score, displayText)

    local i = math.random(#achievements)
    qeeplay.api.GameNetwork.request("unlockAchievement", achievements[i].id)

    qeeplay.api.GameNetwork.show("dashboard")

**Note:**

GameNetwork only supports one provider at a time (you cannot call this API multiple times for
different providers).

<br />

@param providerName
String of the game network provider. ("openfeint" or "gamecenter", case insensitive)

@param params
Additional parameters required by the "openfeint" provider.

-   **productKey**: String of your application's OpenFeint product key (provided by OpenFeint).
-   **secret**: String of your application's product secret (provided by OpenFeint).
-   **displayName**: String of the name to display in OpenFeint leaderboards and other views.

If using GameCenter, the params.listener allows you to specify a callback function.
(Instead of secret keys, your bundle identifier is used automatically to identify your app.)
On successful login, event.data will be 'true'. On unsuccessful init, event.data will be false.
When problems such as network errors occur, event.errorCode (integer) and event.errorString
(string) will be defined.

Also be aware that iOS backgrounding will cause your app to automatically log out your user
from Game Center. When the app is resumed, Game Center will automatically try to re-login
your user. The callback function you specified here will be invoked again telling you the
result of that re-login attempt. Thus, this callback function exists for the life of your
application. With Game Center, it is advisable to avoid calling other Game Center functions
when the user is not logged in.

@return Nothing.

]]
function M.init(providerName, params)
    if provider then
        ccerror("[qeeplay.api.GameNetwork] ERR, init() GameNetwork already init")
        return false
    end

    if type(params) ~= "table" then
        ccerror("[qeeplay.api.GameNetwork] ERR, init() invalid params")
        return false
    end

    providerName = string.upper(providerName)
    if providerName == "GAMECENTER" then
        provider = require("qeeplay.api.gamenetwork.GameCenter")
    elseif providerName == "OPENFEINT" then
        provider = require("qeeplay.api.gamenetwork.OpenFeint")
    else
        ccerror("[qeeplay.api.GameNetwork] ERR, init() invalid providerName: %s", providerName)
        return false
    end

    provider.init(params)
    __QEEPLAY_GLOBALS__["api.GameNetwork"] = provider
end

--[[--
Send or request information to/from the game network provider:

**Syntax:**

    GameNetwork.request( command [, params ...] )

**Example:**

    -- For OpenFeint:
    -- setHighScore, leaderboard id, score, display text
    GameNetwork.request("setHighScore", "abc123", 99, "99 sec")

    -- unlockAchievement, achievement id
    GameNetwork.request("unlockAchievement", "1242345322")


**OpenFeint**

Command supported by the OpenFeint provider:

-   getAchievements:

        local achievements = qeeplay.api.GameNetwork.request("getAchievements")
        for achievementId, achievement in pairs(achievements) do
            -- achievement.id (string)
            -- achievement.title (string)
            -- achievement.description (string)
            -- achievement.iconUrl (string)
            -- achievement.gameScore (integer)
            -- achievement.isUnlocked (boolean)
            -- achievement.isSecret (boolean)
        end

-   unlockAchievement: achievement id

        qeeplay.api.GameNetwork.request("unlockAchievement", "1242345322")

-   getLeaderboards:

        local leaderboards = qeeplay.api.GameNetwork.request("getLeaderboards")
        for i, leaderboard = ipairs(leaderboards) do
            -- leaderboard.id (string)
            -- leaderboard.name (string)
            -- leaderboard.currentUserScore (integer)
            -- leaderboard.currentUserScoreDisplayText (string)
            -- leaderboard.descendingScoreOrder (boolean)
        end

-   setHighScore: leaderboard id, score, display text

        qeeplay.api.GameNetwork.request("setHighScore", "abc123", 99, "99 sec")


**GameCenter**

Coming soon.

<br />

@param command
Command string supported by the provider (case insensitive).

@param ...
Parmeters used in the commands.

@return Nothing.

]]
function M.request(command, ...)
    if not provider then
        ccerror("[qeeplay.api.GameNetwork] ERR, request() GameNetwork not init")
        return
    end

    local params = {}
    for i = 1, select("#", ...) do
        params[i] = select(i, ...)
    end
    return provider.request(command, params)
end

--[[--
Shows (displays) information from game network provider on the screen.

For OpenFeint provider, launches the OpenFeint dashboard in one of the following configurations: leaderboards, challenges, achievements, friends, playing or high score.

**Syntax:**

    qeeplay.api.GameNetwork.show(command [, params] )

**Example:**

    qeeplay.api.GameNetwork("leaderboards")

**OpenFeint:**

Command supported by the OpenFeint provider.

-   leaderboard: leaderboard id

        qeeplay.api.GameNetwork.show("leaderboard", "abc123")

-   leaderboards:

        qeeplay.api.GameNetwork.show("leaderboards")

-   achievements:

        qeeplay.api.GameNetwork.show("achievements")

-   challenges:

        qeeplay.api.GameNetwork.show("challenges")

-   friends:

        qeeplay.api.GameNetwork.show("friends")

-   playing:

        qeeplay.api.GameNetwork.show("playing")

-   dashboard:

        qeeplay.api.GameNetwork.show("dashboard")


**GameCenter:**

Coming soon.

<br />

@param command
Strings supported by provider.

@param ...
Parameters used by command.

@return Nothing.

]]
function M.show(command, ...)
    if not provider then
        ccerror("[qeeplay.api.GameNetwork] ERR, request() GameNetwork not init")
        return
    end

    local params = {}
    for i = 1, select("#", ...) do
        params[i] = select(i, ...)
    end
    provider.show(command, params)
end

return M
