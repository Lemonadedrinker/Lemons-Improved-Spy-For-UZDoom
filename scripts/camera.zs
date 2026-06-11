class LIS_ImprovedSpy : EventHandler
{
    private bool destroyMe;
    private int playerCount;
    private Array<LIS_Camera> cameras;
    
    private Vector2 cameraSize;

    private bool uninstallingMod;


    override void WorldLoaded(WorldEvent event)
    {
        cameraSize = (960, 540);
        InitializeCameras();
    }

    override void PlayerDisconnected(PlayerEvent event)
    {
        InitializeCameras();
    }

    override void WorldTick()
    {
        if (uninstallingMod)
        {
            if (!bDESTROYED) Destroy();
            return;
        }
    }

    override bool InputProcess(InputEvent event)
    {
        // Only key press down
        if (event.Type != InputEvent.Type_KeyDown) return false;

        // If either spy button is pressed.
        if (bindings.GetBinding(event.KeyScan) ~== "spynext" || bindings.GetBinding(event.KeyScan) ~== "spyprev")
        {
            EventHandler.SendNetworkEvent("LIS_Spying");
        }

        return false;
    }

    override void NetworkProcess(ConsoleEvent event)
    {
        if (event.Player != ConsolePlayer) return;

        if (event.Name == "LIS_Spying")
        {
            if (players[ConsolePlayer].mo == players[ConsolePlayer].Camera)
            {
                //Console.printf("Spying on self.");
                players[ConsolePlayer].mo.master = null;
                players[ConsolePlayer].mo.bMASTERNOSEE = false;
            }
            else
            {
                //Console.printf("Spying on other.");
                players[ConsolePlayer].mo.master = cameras[ConsolePlayer];
                players[ConsolePlayer].mo.bMASTERNOSEE = true;
            }
        }
        else if (event.Name == "LIS_Uninstalling")
        {
            if (net_arbitrator == event.Player)
            {
                Console.printf("Uninstalling mod. Have a good day!");
                uninstallingMod = true;

                for (int i = 0; i < cameras.Size(); i++)
                {
                    if (cameras[i] != null) cameras[i].Destroy();
                }
            }
            else
            {
                Console.printf("Not uninstalling mod. You must be the arbitrator!");
            }
        }
    } 

    override void RenderUnderlay(RenderEvent event)
    {
        // Only run if spying on other players
        if (!CVar.GetCVar("LIS_Enabled").GetBool() || StatusBar.CPlayer == players[ConsolePlayer]) return;

        TexMan.SetCameraToTexture(cameras[ConsolePlayer], "LIS_view", players[ConsolePlayer].DesiredFOV);

        float scale = CVar.GetCVar("LIS_CameraScale").GetFloat();

        int a, b, screenWidth, screenHeight; 
        [a, b, screenWidth, screenHeight] = Screen.GetViewWindow();

        Vector2 scaledCameraSize = cameraSize * scale;
        Vector2 cameraOffset = (
            (screenWidth - scaledCameraSize.X) * CVar.GetCVar("LIS_PositionX").GetFloat(),
            (screenHeight - scaledCameraSize.Y) * CVar.GetCVar("LIS_PositionY").GetFloat()
        );
        
        //StatusBar.DrawImage("LIS_view", (0, 0), StatusBar.DI_ITEM_LEFT_TOP, scale: (1, 1));
        Screen.DrawTexture(TexMan.CheckForTexture("LIS_view"), false, cameraOffset.X, cameraOffset.Y,
            DTA_ScaleX, scale,
            DTA_ScaleY, scale
        );
    }

    private void InitializeCameras()
    {
        for (int i = 0; i < playerCount; i++)
        {
            if (cameras[i] != null) cameras[i].Destroy();
        }

        playerCount = 0;
        cameras.Clear();

        for (int i = 0; i < players.Size(); i++)
        {
            if (players[i].mo != null) playerCount++;
        }

        // Destroy if only 1 player
        //Console.printf("PlayerCount: %i", playerCount);
        if (playerCount < 2)
        {
            destroyMe = true;
            return;
        }

        // Create a camera for each player
        for (int i = 0; i < playerCount; i++)
        {
            cameras.Push(LIS_Camera(Actor.Spawn("LIS_Camera")));

            if (players[i].mo != null) players[i].mo.bMASTERNOSEE = true;
            //cameras[i].master = players[i].mo;
        }
    }
}

class LIS_Camera : Actor
{
    default {
        +NOGRAVITY
        +MASTERNOSEE
        +CAMFOLLOWSPLAYER
        Radius 0;
        Height 0;
    }

    override void PostBeginPlay()
    {
        /*
        if (master == null)
        {
            Destroy();
            return;
        }
        */
    }

    override void Tick()
    {
        Super.Tick();
        /*
        if (master == null)
        {
            Destroy();
            return;
        }
        */

        //Warp(master, master.radius / 2, 0, master.height * 0.75, flags: WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE | WARPF_WARPINTERPOLATION | WARPF_COPYINTERPOLATION | WARPF_COPYVELOCITY | WARPF_COPYPITCH | WARPF_BOB);
        //Warp(master, master.radius / 2, 0, master.height * 0.9, flags: WARPF_NOCHECKPOSITION | WARPF_COPYPITCH | WARPF_COPYVELOCITY | WARPF_INTERPOLATE | WARPF_WARPINTERPOLATION | WARPF_COPYINTERPOLATION);
    }
}