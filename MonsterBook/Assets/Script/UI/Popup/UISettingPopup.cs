using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class UISettingPopup : UIBasePopup
{
    [System.Serializable]
    public enum State
    {
        Open,
        ScreenMode,
        Resolution,
        GlobalVolume,
        BGMVolume,
        SFXVolume,
        Close,
    }

    [SerializeField, ReadOnly] private State curState;
    [SerializeField, ReadOnly]
    private int selectMenuIndex;
    [SerializeField]
    private State[] menuStates;
    [SerializeField]
    private GameObject[] menuHighlights;

    bool isMove = false;

    [SerializeField]
    private TextMeshProUGUI screenModeText;

    [SerializeField]
    private string[] screenModeDescriptions;
    [SerializeField]
    private FullScreenMode[] screenModes;

    [SerializeField, ReadOnly]
    private int selectScreenModeIndex;

    [SerializeField]
    private TextMeshProUGUI resolutionText;

    [SerializeField]
    private Vector2Int[] resolutions;
    [SerializeField, ReadOnly]
    private int selectResolutionIndex;

    [SerializeField]
    private Slider globalVolumeSlider;
    [SerializeField]
    private Slider bgmVolumeSlider;
    [SerializeField]
    private Slider sfxVolumeSlider;

    private PlayerAction action;

    private UISettingPopupData settingPopupData;

    public override void Init(UIData uiData)
    {
        settingPopupData = uiData as UISettingPopupData;

        action = new PlayerAction();

        action.UI.Move.performed += val => Move(val.ReadValue<Vector2>());
        action.UI.Move.canceled += val => EndMove();
        action.UI.Esc.started += val => Close();

        action.UI.Enable();

        var currentScreenMode = PlayerPrefs.GetInt("ScreenMode", 0);

        for (var i = 0; i < screenModes.Length; ++i)
        {
            if ((int)screenModes[i] == currentScreenMode)
            {
                selectScreenModeIndex = i;
                break;
            }
        }
        screenModeText.text = screenModeDescriptions[selectScreenModeIndex];

        var currentScreenWidth = PlayerPrefs.GetInt("ScreenX", 1280);

        for (var i = 0; i < resolutions.Length; ++i)
        {
            if (resolutions[i].x == currentScreenWidth)
            {
                selectResolutionIndex = i;
                break;
            }
        }
        var currentResolution = resolutions[selectResolutionIndex];
        resolutionText.text = $"{currentResolution.x} x {currentResolution.y}";

        globalVolumeSlider.value = PlayerPrefs.GetFloat("GlobalVolume", 0);
        print(PlayerPrefs.GetFloat("GlobalVolume", 0));
        bgmVolumeSlider.value = PlayerPrefs.GetFloat("BGMVolume", 0);
        print(PlayerPrefs.GetFloat("BGMVolume", 0));
        sfxVolumeSlider.value = PlayerPrefs.GetFloat("SFXVolume", 0);
        print(PlayerPrefs.GetFloat("SFXVolume", 0));

    }

    public override void EndOpen()
    {
        base.EndOpen();
        curState = State.ScreenMode;
    }

    public void ChangeScreenMode(int direction)
    {
        selectScreenModeIndex += direction;

        if (selectScreenModeIndex < 0)
        {
            selectScreenModeIndex = 0;
        }
        else if (selectScreenModeIndex >= screenModes.Length)
        {
            selectScreenModeIndex = screenModes.Length - 1;
        }

        var currentResolution = Screen.currentResolution;
        screenModeText.text = screenModeDescriptions[selectScreenModeIndex];

        SettingManager.Instance.ChangeScreenMode(screenModes[selectScreenModeIndex]);
    }

    public void ChangeResolution(int direction)
    {
        selectResolutionIndex += direction;

        if (selectResolutionIndex < 0)
        {
            selectResolutionIndex = 0;
        }
        else if (selectResolutionIndex >= resolutions.Length)
        {
            selectResolutionIndex = resolutions.Length - 1;
        }

        var currentResolution = resolutions[selectResolutionIndex];
        resolutionText.text = $"{currentResolution.x} x {currentResolution.y}";

        SettingManager.Instance.ChangeResolution(resolutions[selectResolutionIndex]);
    }

    public void ChangeGlobalVolume(float volume)
    {
        SoundManager.ChangeGlobalVolume(volume);
    }

    public void ChangeBGMVolume(float volume)
    {
        SoundManager.ChangeBGMVolume(volume);
    }

    public void ChangeSFXVolume(float volume)
    {
        SoundManager.ChangeSFXVolume(volume);
    }

    private void Move(Vector2 dir)
    {
        if (curState == State.Open || curState == State.Close)
            return;

        if (isMove)
            return;

        menuHighlights[selectMenuIndex].SetActive(false);
        isMove = true;

        var absX = Mathf.Abs(dir.x);
        var absY = Mathf.Abs(dir.y);

        switch (curState)
        {
            case State.ScreenMode:
                if (absX > absY)
                {
                    ChangeScreenMode((int)dir.x);
                }
                else if (absY > absX)
                {
                    selectMenuIndex += (int)dir.y;
                }
                break;
            case State.Resolution:
                if (absX > absY)
                {
                    ChangeResolution((int)dir.x);
                }
                else if (absY > absX)
                {
                    selectMenuIndex += (int)dir.y;
                }
                break;
            case State.GlobalVolume:
                if (absX > absY)
                {
                    selectMenuIndex += (int)dir.x;
                }
                else if (absY > absX)
                {
                    globalVolumeSlider.value -= (int)dir.y * 4;
                }
                break;
            case State.BGMVolume:
                if (absX > absY)
                {
                    selectMenuIndex += (int)dir.x;
                }
                else if (absY > absX)
                {
                    bgmVolumeSlider.value -= (int)dir.y * 4;
                }
                break;
            case State.SFXVolume:
                if (absX > absY)
                {
                    selectMenuIndex += (int)dir.x;
                }
                else if (absY > absX)
                {
                    sfxVolumeSlider.value -= (int)dir.y * 4;
                }
                break;
        }

        if (selectMenuIndex < 0)
        {
            selectMenuIndex = 0;
        }
        else if (selectMenuIndex >= menuStates.Length)
        {
            selectMenuIndex = menuStates.Length - 1;
        }

        menuHighlights[selectMenuIndex].SetActive(true);
        curState = menuStates[selectMenuIndex];
    }

    private void EndMove()
    {
        isMove = false;
    }

    public override void EndClose()
    {
        settingPopupData.endCloseAction?.Invoke();
        base.EndClose();
    }

    private void OnDisable()
    {
        action.UI.Disable();
    }

}