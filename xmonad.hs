import XMonad
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
import XMonad.Actions.WindowGo
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
-- Don't like it as much as I thought I would
-- Seriously future self. stahp.
-- import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops -- For _NET_ACTIVE_WINDOW
import XMonad.Util.Run
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Paste
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Spacing
import System.IO
import System.Exit -- graceful closing of X11

myTab = defaultTheme
    { activeColor         = "black"
    , inactiveColor       = "black"
    , urgentColor         = "yellow"
    , activeBorderColor   = "orange"
    , inactiveBorderColor = "#222222"
    , urgentBorderColor   = "black"
    , activeTextColor     = "orange"
    , inactiveTextColor   = "#222222"
    , urgentTextColor     = "yellow"
    }

myMHook = composeAll
    [ className =? "Firefox"        --> doShift "2:web"
--    , className =? "Pidgin"         --> doShift "3:chat"
--    , className =? "Thunderbird"    --> doShift "4:work"
    , className =? "MPlayer"        --> doFloat
    , className =? "mplayer2"       --> doFloat
    , className =? "mpv"            --> doFloat
    , className =? "Gtkdialog"      --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , isFullscreen                  --> doFullFloat
    , isDialog                      --> doCenterFloat
    ]

-- myFade = fadeInactiveLogHook fadeAmount
--     where fadeAmount = 0.85

-- Probably a better way to do this...
myL1 = noBorders(myTabs) ||| smartBorders(tiled ||| grid)
    where
        myTabs  = tabbed shrinkText myTab
        tiled   = layoutHintsToCenter $ smartSpacing 2 $ ResizableTall nmaster delta ratio []
        grid    = smartSpacing 6 $ Grid
        nmaster = 1
        delta   = 3/100
        ratio   = 1/2
myL2 = noBorders(Full ||| myTabs) ||| smartBorders(grid)
    where
        myTabs  = tabbed shrinkText myTab
        grid    = smartSpacing 6 $ Grid

myLayoutHook = onWorkspace "2:web" myL2 $ myL1
myHandleEventHook = hintsEventHook <+> docksEventHook
myBrowser = "Firefox"
myTerminal = "exec /usr/bin/urxvtc"

main = do
    xmproc <- spawnPipe "exec xmobar /home/jenic/.xmobarrc"
    xmproc <- spawnPipe "exec xmobar /home/jenic/.xmobar2rc"
    xmonad $ ewmh defaultConfig
        { workspaces = ["1:dev","2:web","3","4","5"]
        , manageHook = manageDocks <+> (myMHook <+> manageHook defaultConfig)
        , layoutHook = avoidStruts $ myLayoutHook
        , handleEventHook = myHandleEventHook
--        , logHook = myFade <+> dynamicLogWithPP xmobarPP
        , logHook = dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                } >> updatePointer (Relative 0.5 0.5)
        , terminal = myTerminal
        , focusedBorderColor = "#333333"
        , normalBorderColor = "#222222"
        , focusFollowsMouse = False
        , modMask = mod4Mask -- Action = Superkey
        -- xev command is your friend
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
        , ((mod4Mask .|. controlMask, xK_s), spawn "sh /home/jenic/bin/cpyqs")
        , ((0, xK_Print), spawn "scrot")
        , ((controlMask, xK_Print), spawn "scrot -s")
        , ((mod4Mask, xK_g), goToSelected defaultGSConfig)
        , ((0, xK_Insert), pasteSelection)
        , ((mod4Mask, xK_f), runOrRaise myBrowser (className =? "Firefox"))
        , ((mod4Mask, xK_m), raiseMaybe (runInTerm "-title mutt" "mutt") (title =? "mutt"))
        -- MPD stuff
        , ((mod4Mask, xK_c), spawn "mpc -q toggle")
        , ((0, 0x1008ff14), spawn "mpc -q toggle")
        , ((mod4Mask, xK_b), spawn "mpc -q next")
        , ((0, 0x1008ff17), spawn "mpc -q next")
        , ((0, 0x1008ff16), spawn "mpc -q prev")
        , ((mod4Mask, xK_Up), spawn "mpc -q volume +10")
        , ((0, 0x1008ff13), spawn "mpc -q volume +10")
        , ((mod4Mask, xK_Down), spawn "mpc -q volume -10")
        , ((0, 0x1008ff11), spawn "mpc -q volume -10")
        ]
