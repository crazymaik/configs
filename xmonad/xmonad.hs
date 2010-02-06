
import Control.Monad (liftM)
import Data.List

import XMonad

import XMonad.Actions.WindowBringer

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName

import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ThreeColumns

import XMonad.ManageHook

import XMonad.Prompt
import XMonad.Prompt.Shell

import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Scratchpad

import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "xfce4-terminal"

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod1Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = map show [1..9] ++ ["im"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#cccccc"
myFocusedBorderColor = "#cd8b00"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modMask,               xK_p     ), shellPrompt myXPConfig)

    -- launch gmrun
    , ((modMask .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window 
    , ((modMask .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modMask,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modMask,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modMask,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modMask,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask              , xK_period), sendMessage (IncMasterN (-1)))

    -- Quit xmonad
    , ((modMask .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modMask              , xK_q     ), restart "xmonad" True)

    -- im workspace
    , ((modMask              , xK_i     ), windows $ W.greedyView "im")

    -- goto workspace and focus window
    , ((modMask .|. shiftMask, xK_g     ), gotoMenu)

    -- bring and focus window
    , ((modMask .|. shiftMask, xK_b     ), bringMenu)

    , ((modMask              , xK_s     ), scratchpadSpawnActionTerminal "urxvt")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

--moreKeys =
--  [ ("M-i", windows $ W.greedyView "im") ]

------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

myLayout = avoidStruts $ onWorkspace "im" cols $ (tiled ||| Mirror tiled ||| noBorders Full)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

     cols = ThreeCol 1 (3/100) (1/2)

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = (composeAll . concat)
    [ [className =? c --> doFloat | c <- byClass]
    , [(liftM $ isInfixOf t) title --> doFloat | t <- byTitle]
    , [resource =? r --> doFloat | r <- byResource]
    , [className =? c --> doF (W.shift "im") | c <- shiftClassToIM]
    , [className =? "Do" --> doIgnore]
    ] <+> scratchpadManageHook (W.RationalRect 0.3 0.25 0.4 0.5)
      <+> manageHook defaultConfig
  where byClass = ["Gimp", "MPlayer", "Totem"]
        byTitle = ["Downloads", "Preferences", "Save As..."]
        byResource = []
        shiftClassToIM = ["Skype", "Pidgin"]

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True


------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--
--myLogHook = dynamicLogDzen

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = setWMName "LG3D"

------------------------------------------------------------------------

myXPConfig :: XPConfig
myXPConfig = defaultXPConfig
  { font              = myFont2
  --, bgColor           = "black"
  --, fgColor           = "#999999"
  --, fgHLight          = "#ffffff"
  --, bgHLight          = "#4c7899"
  --, promptBorderWidth = 0
  --, position          = Bottom
  , height            = 24
  , historySize       = 128 
  }

------------------------------------------------------------------------

myFont  = "-*-helvetica-medium-r-normal-*-18-*-*-*-*-*-iso10646-1"
myFont2 = "-*-dejavu sans mono-medium-r-*-*-16-*-*-*-*-*-iso10646-*"

myStatusbar = "dzen2 -x '300' -y '0' -h '24' -w '1120' -ta 'l' -fg '#0f0f0f' -bg '#e2e2e2' -fn '" ++ myFont2 ++ "'"

myDzenPP h = defaultPP { ppOutput = hPutStrLn h }

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main =
  do dzenOut <- spawnPipe myStatusbar
     xmonad $ defaultConfig {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook <+> manageDocks,
        logHook            = dynamicLogWithPP $ myDzenPP dzenOut,
        startupHook        = myStartupHook
    }
    --`additionalKeysP` moreKeys