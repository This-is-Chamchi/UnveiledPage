using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class InGameUI : MonoBehaviour
{
    enum State
    {
        None,
        Dialogue,
        Pause,
        Setting,
    }

    [SerializeField, ReadOnly] private State curState;

    [Serializable]
    public struct DialogueUI
    {
        public DialogueDataContainer container;

        [Header("Data")]
        public int curHeadIndex;
        [ReadOnly] public int curTailIndex;

        [Header("UI")]
        public GameObject panel;
        public TMPro.TMP_Text dialogueText;
    }

    [Serializable]
    struct PauseUI
    {
        public Image[] menuImage;
        public GameObject[] selectImage;

        public int pauseIndex;
        public GameObject pausePanel;
    }

    [Serializable]
    struct SettingUI
    {
        public GameObject graphicImage;
        public GameObject audioImage;

        public GameObject[] screenMode;
        public Image screenModeImage;

        public GameObject[] resolution;
        public Image resolutionImage;

        public Image[] globalAudio;
        public Image globalAudioImage;

        public Image[] vfxAudio;
        public Image vfxAudioImage;

        public Image[] bgmAudio;
        public Image bgmAudioImage;

        public GameObject settingPanel;
        [ReadOnly] public Vector2 index;
    }


    [SerializeField] private DialogueUI dialougeUI;
    [SerializeField] private PauseUI pauseUI;

    [SerializeField] private SettingUI settingUI;

    private PlayerAction action;


    private void Awake()
    {
        action = new PlayerAction();

        action.UI.Move.performed += val => Move(val.ReadValue<Vector2>());
        action.UI.Select.started += val => Enter();
        action.UI.Esc.started += val => Escape();

        action.UI.Enable();        
    }

    private void Start()
    {
        for (int i = 0; i < pauseUI.menuImage.Length; i++)
        {
            pauseUI.menuImage[i].color = new Color32(255, 255, 255, 100);
            pauseUI.selectImage[i].gameObject.SetActive(false);
        }

        pauseUI.pausePanel.SetActive(false);
        dialougeUI.panel.SetActive(false);
        settingUI.settingPanel.SetActive(false);
    }

    public void Enter()
    {
        switch (curState)
        {
            case State.None:
                break;
            case State.Dialogue:
                if (dialougeUI.curTailIndex >= dialougeUI.container.Datas[dialougeUI.curHeadIndex].Datas.Length - 1)
                {
                    dialougeUI.panel.SetActive(false);
                    GameManager.SetInGameInput(true);                    
                    curState = State.None;
                    return;
                }
                dialougeUI.dialogueText.text = dialougeUI.container.Datas[dialougeUI.curHeadIndex].Datas[++dialougeUI.curTailIndex].text;
                break;
            case State.Pause:
                switch(pauseUI.pauseIndex)
                {
                    case 0:
                        ClosePause();
                        break;
                    case 1:
                        ClosePause();
                        OpenSetting();                        
                        break;
                    case 2:
                        SceneManager.LoadScene(0);
                        break;
                }
                break;
            case State.Setting:
                break;
        }
    }

    public void Escape()
    {        
        switch (curState)
        {
            case State.None:
                OpenPause();
                break;
            case State.Dialogue:
                break;
            case State.Pause:
                ClosePause();
                break;
            case State.Setting:
                CloseSetting();
                OpenPause();
                break;
        }
    }

    public void Move(Vector2 move)
    {
        switch (curState)
        {
            case State.None:
                break;
            case State.Dialogue:
                break;
            case State.Pause:
                pauseUI.pauseIndex += (int)move.y;
                if (pauseUI.pauseIndex < 0) pauseUI.pauseIndex = 0;
                else if (pauseUI.pauseIndex >= pauseUI.menuImage.Length - 1) pauseUI.pauseIndex = pauseUI.menuImage.Length - 1;
                SelectPause();
                break;
            case State.Setting:

                SelectSetting();
                break;
        }
    }

    #region Dialogue
    public void ShowDialogue(int hIdx = 0)
    {     
        if (hIdx < 0 || hIdx >= dialougeUI.container.Length) return;
        curState = State.Dialogue;
        action.UI.Enable();
        GameManager.SetInGameInput(false);
        dialougeUI.panel.SetActive(true);
        dialougeUI.curTailIndex = 0;
        if (hIdx == 0) dialougeUI.dialogueText.text = dialougeUI.container.Datas[dialougeUI.curHeadIndex].Datas[dialougeUI.curTailIndex].text;
        else dialougeUI.dialogueText.text = dialougeUI.container.Datas[dialougeUI.curHeadIndex = hIdx].Datas[dialougeUI.curTailIndex].text;
    }

    public void ShowDialogue(int hIdx = 0, int tIdx = 0)
    {        
        if (hIdx < 0 || hIdx >= dialougeUI.container.Length) return;
        action.UI.Enable();
        dialougeUI.panel.SetActive(true);        
        if (hIdx == 0) dialougeUI.dialogueText.text = dialougeUI.container.Datas[dialougeUI.curHeadIndex].Datas[0].text;
        else dialougeUI.dialogueText.text = dialougeUI.container.Datas[dialougeUI.curHeadIndex = hIdx].Datas[0].text;
    }

    #endregion

    public void OpenPause()
    {
        curState = State.Pause;
        pauseUI.pausePanel.SetActive(true);
        SelectPause();
        GameManager.SetInGameInput(false);
    }

    public void ClosePause()
    {
        curState = State.None;
        pauseUI.pausePanel.SetActive(false);
        GameManager.SetInGameInput(true);
    }

    public void SelectPause()
    {
        for (int i = 0; i < pauseUI.menuImage.Length; i++)
        {
            pauseUI.menuImage[i].color = new Color32(255, 255, 255, 100);
            pauseUI.selectImage[i].gameObject.SetActive(false);
        }
        pauseUI.menuImage[pauseUI.pauseIndex].color = new Color32(255, 255, 255, 255);
        pauseUI.selectImage[pauseUI.pauseIndex].SetActive(true);
    }

    public void OpenSetting()
    {
        curState = State.Setting;
        GameManager.SetInGameInput(false);
        settingUI.settingPanel.SetActive(true);
        settingUI.index = Vector2.zero;
        SelectSetting();
    }

    public void CloseSetting()
    {
        curState = State.None;
        settingUI.settingPanel.SetActive(false);
        GameManager.SetInGameInput(true);
    }

    public void SelectSetting()
    {
        settingUI.graphicImage.SetActive(settingUI.index.x == 0);
        settingUI.audioImage.SetActive(settingUI.index.x == 1);
        for (int i = 0; i < settingUI.screenMode.Length; i++)
        {
            settingUI.screenMode[i].SetActive(settingUI.index.x == 0 && settingUI.index.y == 0);
        }
        for (int i = 0; i < settingUI.resolution.Length; i++)
        {
            settingUI.resolution[i].SetActive(settingUI.index.x == 0 && settingUI.index.y == 1);
        }

    }

}
