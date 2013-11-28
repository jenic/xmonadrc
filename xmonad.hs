import XMonad
import XMonad.Actions.UpdatePointer
import XMonad.Actions.GridSelect
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.Mosaic
import XMonad.Layout.LayoutHints
import XMonad.Layout.PerWorkspace
import System.IO

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

myManageHook = composeAll
    [ className =? "Firefox"        --> doShift "2:web"
    , className =? "Pidgin"         --> doShift "3:chat"
    , className =? "Thunderbird"    --> doShift "4:email"
    , className =? "MPlayer"        --> doFloat
    , className =? "mplayer2"       --> doFloat
    , className =? "mpv"            --> doFloat
    , className =? "Gtkdialog"      --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , isFullscreen                  --> doFullFloat
    , isDialog                      --> doCenterFloat
    ]

myFade = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.85

-- Probably a better way to do this...
myL1 = noBorders(myTabs) ||| smartBorders(tiled ||| mosaic 2 [3,2])
    where
        myTabs  = layoutHints $ tabbed shrinkText myTab
        tiled   = layoutHints $ ResizableTall nmaster delta ratio []
        nmaster = 1
        delta   = 2/100
        ratio   = 1/2
myL2 = noBorders(Full ||| myTabs) ||| smartBorders(mosaic 2 [3,2])
    where
        myTabs  = layoutHints $ tabbed shrinkText myTab

myLayoutHook = onWorkspace "2:web" myL2 $ myL1

main = do
    xmproc <- spawnPipe "exec xmobar /home/jenic/.xmobarrc"
    xmproc <- spawnPipe "exec xmobar /home/jenic/.xmobar2rc"
    xmonad $ defaultConfig
        { workspaces = ["1:dev","2:web","3:chat","4:email","5","6","7"]
        , manageHook = manageDocks <+> (myManageHook <+> manageHook defaultConfig)
        , layoutHook = avoidStruts  $    myLayoutHook
        , logHook = myFade <+> dynamicLogWithPP xmobarPP
                { ppOutput = hPutStrLn xmproc
                , ppTitle = xmobarColor "green" "" . shorten 50
                } >> updatePointer (Relative 0.5 0.5)
        , terminal = "exec /usr/bin/urxvtc"
        , focusedBorderColor = "#333333"
        , normalBorderColor = "#222222"
        , focusFollowsMouse = False
        , modMask = mod4Mask -- Action = Superkey
        } `additionalKeys`
        [ ((mod4Mask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
        , ((mod4Mask, xK_c), spawn "mpc -q toggle")
        , ((mod4Mask .|. controlMask, xK_s), spawn "sh /home/jenic/bin/cpyqs")
        , ((mod4Mask, xK_b), spawn "mpc -q next")
        , ((mod4Mask, xK_Up), spawn "mpc -q volume +10")
        , ((mod4Mask, xK_Down), spawn "mpc -q volume -10")
        , ((controlMask, xK_Print), spawn "scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((mod4Mask, xK_g), goToSelected defaultGSConfig)
        ]
