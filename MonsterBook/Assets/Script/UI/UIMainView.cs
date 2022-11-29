using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEngine.Events;

public class UIMainView : UIBaseView
{
    [System.Serializable]
    public enum State
    {
        Fade,
        Press,
        StartGame,
        Setting,
        Exit,
    }

    [SerializeField]
    Animator cameraAnimator;

    [SerializeField, ReadOnly] private State curState;
    [SerializeField] private GameObject pressKey;

    [SerializeField, ReadOnly]
    private int selectMenuIndex;

    bool isMove = false;

    [SerializeField]
    private State[] menuStates;

    [SerializeField]
    private GameObject[] menuObjects;
    [SerializeField]
    private GameObject[] menuHighlights;

    [SerializeField]
    private float scaleAnimationTime;
    [SerializeField]
    private AmountRangeVector3 scaleAnimationRange;

    [SerializeField] private Event[] openBookEvent;
    public UnityEvent enterTitleMenuEvent;
    [SerializeField] private Animator bookAni;

    private Coroutine scaleOutCoroutine;
    private Coroutine scaleInCoroutine;

    private PlayerAction action;

    private void Awake()
    {
        action = new PlayerAction();

        action.UI.Move.performed += val => Move(val.ReadValue<Vector2>());
        action.UI.Move.canceled += val => EndMove();
        action.UI.Select.started += val => Select();
    }

    private void OnEnable()
    {
        action.UI.Enable();
    }

    private void OnDisable()
    {
        action.UI.Disable();
    }

    protected override void Start()
    {
        base.Start();

        action.UI.Disable();

        for (var i = 0; i < menuObjects.Length; ++i)
        {
            menuObjects[i].SetActive(false);
            menuHighlights[i].SetActive(false);
        }

        FadeController.Instance.FadeOut(() =>
        {
            curState = State.Press;
            InputSystem.onAnyButtonPress.CallOnce(ctrl => PressAnyKey());
        });
    }

    public override void Init(UIData uiData)
    {

    }

    private void PressAnyKey()
    {
        if (curState == State.Press)
        {
            StartCoroutine(PressRoutine());
        }
    }

    private IEnumerator PressRoutine()
    {
        pressKey.SetActive(false);

        bookAni.SetTrigger("Open");
        for (int i = 0; i < openBookEvent.Length; i++)
        {
            openBookEvent[i].StartEvent();
        }

        enterTitleMenuEvent?.Invoke();

        yield return YieldInstructionCache.waitForSeconds(4.6f);
        for (var i = 0; i < menuObjects.Length; ++i)
        {
            menuObjects[i].SetActive(true);
        }

        Move(Vector2.zero);
        isMove = false;

        curState = State.StartGame;
        action.UI.Enable();
    }

    private void Move(Vector2 dir)
    {
        if (isMove)
            return;

        isMove = true;

        if (scaleOutCoroutine != null)
        {
            StopCoroutine(scaleOutCoroutine);
        }
        scaleOutCoroutine = StartCoroutine(CoScaleAnimation(menuObjects[selectMenuIndex].transform, -1));
        menuHighlights[selectMenuIndex].SetActive(false);

        selectMenuIndex += (int)dir.x;

        if (selectMenuIndex < 0)
        {
            selectMenuIndex = 0;
        }
        else if (selectMenuIndex >= menuObjects.Length)
        {
            selectMenuIndex = menuObjects.Length - 1;
        }

        curState = menuStates[selectMenuIndex];
        if (scaleInCoroutine != null)
        {
            StopCoroutine(scaleInCoroutine);
        }
        scaleInCoroutine = StartCoroutine(CoScaleAnimation(menuObjects[selectMenuIndex].transform, 1));
        menuHighlights[selectMenuIndex].SetActive(true);
    }

    private void EndMove()
    {
        isMove = false;
    }

    private void Select()
    {
        switch (curState)
        {
            case State.StartGame:
                action.UI.Disable();
                cameraAnimator.SetTrigger("EnterGame");
                SoundManager.StopBGM(1.5f);
                FadeController.Instance.FadeIn(() =>
                {
                    SceneManager.LoadScene(1);
                });
                break;
            case State.Setting:
                cameraAnimator.SetTrigger("EnterSetting");
                Game.UI.UIController.Instance.OpenPopup(new UISettingPopupData()
                {
                    endCloseAction = () =>
                    {
                        cameraAnimator.SetTrigger("ExitSetting");
                        gameObject.SetActive(true);
                    }
                });
                gameObject.SetActive(false);
                action.UI.Disable();
                break;
            case State.Exit:
#if UNITY_EDITOR
                UnityEditor.EditorApplication.isPlaying = false;
#else
                Application.Quit();
#endif
                break;
        }
    }

    IEnumerator CoScaleAnimation(Transform menu, int scaleDirection)
    {
        var time = 0f;
        var lerpTime = time / scaleAnimationTime;

        while (lerpTime <= 1)
        {
            time += Time.deltaTime;
            lerpTime = time / scaleAnimationTime;

            if (scaleDirection > 0)
            {
                menu.localScale = Vector3.Lerp(scaleAnimationRange.min, scaleAnimationRange.max, lerpTime);
            }
            else
            {
                menu.localScale = Vector3.Lerp(scaleAnimationRange.max, scaleAnimationRange.min, lerpTime);
            }

            yield return null;
        }
    }

    private void OnDestroy()
    {
        action.UI.Disable();
        //action.UI.Move.performed -= val => Move(val.ReadValue<Vector2>());
        //action.UI.Select.started -= val => Select();
    }

}
