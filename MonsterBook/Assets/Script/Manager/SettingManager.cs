using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingManager : Singleton<SettingManager>
{
    public void ChangeScreenMode(FullScreenMode screenMode)
    {
        var currentResolution = Screen.currentResolution;
        Screen.SetResolution(currentResolution.width, currentResolution.height, screenMode);

        PlayerPrefs.SetInt("ScreenMode", (int)screenMode);
    }

    public void ChangeResolution(Vector2Int resolution)
    {
        var currentScreenMode = Screen.fullScreenMode;

        PlayerPrefs.SetInt("ScreenX", resolution.x);
        PlayerPrefs.SetInt("ScreenY", resolution.y);

        Screen.SetResolution(resolution.x, resolution.y, currentScreenMode);
    }


}
