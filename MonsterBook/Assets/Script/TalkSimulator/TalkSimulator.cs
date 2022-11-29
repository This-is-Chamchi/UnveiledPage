using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using Sirenix.OdinInspector;

public class TalkSimulator : Singleton<TalkSimulator>
{
    [SerializeField]
    private ScenarioData scenarioData;

    [SerializeField]
    private int currentIndex = 0;

    public float textDisplayTimePerCharacter = 0.1f;

    [SerializeField]
    private TalkElementData currentTalkData;

    [SerializeField]
    private UITalkCharacter currentTalkCharacter;

    [SerializeField]
    private UITalkCharacter[] talkCharacterSlots;

    [ReadOnly]
    private SerializableDictionary<string, UITalkCharacter> cachingCharacterSlotDic = new SerializableDictionary<string, UITalkCharacter>();

    [SerializeField]
    private UIBaseText characterNameText;
    [SerializeField]
    private UIBaseText talkText;

    public UnityEvent startScenarioEvnet;
    public UnityEvent endScenarioEvnet;

    public UnityEvent nextTalkEvent;
    public UnityEvent startTalkEvent;
    public UnityEvent endTalkEvent;

    private Coroutine textDisplayAnimation;

    [SerializeField]
    private bool isAllowNextTalk = false;

    [SerializeField]
    private bool isSkipHold = false;

    [SerializeField]
    private float skipHoldTime = 2f;
    private float currentSkipHoldTime = 0f;

    private PlayerAction action;

    [SerializeField]
    private GameObject nextButton;

    [Header("[UI Object]")]
    [SerializeField] private GameObject dialogueRect;
    [SerializeField] private GameObject skipRect;


    protected override void Awake()
    {
        base.Awake();
        action = new PlayerAction();
        action.UI.Select.started += val => NextTalk();
        action.UI.Skip.started += val => StartSkipHold();
    }

    private void OnEnable()
    {
        //action.Enable();
    }

    [Button("시나리오 시작")]
    public void StartScenario(ScenarioData scenarioData)
    {
        action.Enable();
        GameManager.SetInGameInput(false);
        dialogueRect.SetActive(true);
        skipRect.SetActive(true);
        this.scenarioData = scenarioData;        
        //NextTalk에서 ++하고 시작하기 때문에, -1부터 진행 해주세요.
        currentIndex = -1;
        isAllowNextTalk = true;
        startScenarioEvnet?.Invoke();
        NextTalk();
    }

    public void EndScenario()
    {
        action.Disable();
        endScenarioEvnet?.Invoke();
        dialogueRect.SetActive(false);
        skipRect.SetActive(false);
        GameManager.SetInGameInput(true);
    }

    public void NextTalk()
    {
        if (!isAllowNextTalk)
            return;

        nextTalkEvent?.Invoke();

        // 만약, 잔여 대화가 존재하면, 자동으로 다음 대화를 시작합니다.
        if (currentIndex < scenarioData.TalkElementDataList.Count - 1)
        {
            ++currentIndex;
            currentTalkData = scenarioData.GetTalkElementData(currentIndex);

            StartTalk();
        }
        else
        {
            EndScenario();
        }
    }

    public void StartTalk()
    {
        nextButton.gameObject.SetActive(false);
        isAllowNextTalk = false;
        startTalkEvent?.Invoke();

        if (textDisplayAnimation != null)
        {
            StopCoroutine(textDisplayAnimation);
        }

        AddCharacter(currentTalkData);
        characterNameText.SetText(currentTalkData.CharacterName);

        //대화 하는 친구면, 화이트, 1배로
        //대화 안하고 있으면 검정 틴트, 크기 0.9배로
        AutoHighlight(currentTalkData.CharacterName);

        textDisplayAnimation = StartCoroutine(CoTextDisplayAnimation());
    }

    public void EndTalk()
    {
        isAllowNextTalk = true;
        nextButton.gameObject.SetActive(true);
        endTalkEvent?.Invoke();
    }

    //결정버튼 누르면, 타자기 연출 스킵하고 다 뜨게 만들기
    public void SkipTextDisplayAnimation()
    {
        if (textDisplayAnimation != null)
        {
            StopCoroutine(textDisplayAnimation);
        }

        talkText.SetText(currentTalkData.Talk);
    }

    //스토리 스킵 기능
    public void SkipScenario()
    {
        EndScenario();
    }

    public bool ContainCharacter(string characterName)
    {
        return cachingCharacterSlotDic.ContainsKey(characterName);
    }

    private void AddCharacter(TalkElementData talkData)
    {
        UITalkCharacter slot = null;

        switch (talkData.CharacterStandAnchor)
        {
            case TalkElementData.CharacterStandAnchorType.Left:
                slot = talkCharacterSlots[0];
                break;
            case TalkElementData.CharacterStandAnchorType.Right:
                slot = talkCharacterSlots[1];
                break;
        }

        if (cachingCharacterSlotDic.ContainsKey(talkData.CharacterName))
        {
            cachingCharacterSlotDic[talkData.CharacterName] = slot;
        }
        else
        {
            cachingCharacterSlotDic.Add(talkData.CharacterName, slot);
        }

        slot.ChangeCharacter(talkData.CharacterName, talkData.Character);
        slot.gameObject.SetActive(true);

    }

    private void RemoveCharacter(string characterName)
    {
        if (cachingCharacterSlotDic.ContainsKey(characterName))
        {
            var slot = cachingCharacterSlotDic[characterName];
            slot.gameObject.SetActive(false);

            cachingCharacterSlotDic.Remove(characterName);
        }
    }

    public void AutoHighlight(string name)
    {
        for (var i = 0; i < talkCharacterSlots.Length; ++i)
        {
            if (talkCharacterSlots[i].GetCharacterName().Equals(name) && !talkCharacterSlots[i].IsShow)
            {
                talkCharacterSlots[i].Show();
            }
            else
            {
                talkCharacterSlots[i].Hide();
            }
        }
    }


    //텍스트는 타자기 연출에 속도 n초
    IEnumerator CoTextDisplayAnimation()
    {
        var waitForTime = new WaitForSeconds(textDisplayTimePerCharacter);
        var currentTextIndex = 0;

        StringBuilder stBuilder = new StringBuilder();

        while (currentTalkData.Talk.Length != currentTextIndex)
        {
            stBuilder.Append(currentTalkData.Talk[currentTextIndex]);
            ++currentTextIndex;

            talkText.SetText(stBuilder.ToString());
            yield return waitForTime;
        }

        EndTalk();
    }

    private void StartSkipHold()
    {
        currentSkipHoldTime = 0f;
        isSkipHold = true;
    }

    private void Update()
    {
        if (!isSkipHold)
            return;

        currentSkipHoldTime += Time.deltaTime;
        if (currentSkipHoldTime >= skipHoldTime)
        {
            isSkipHold = false;
            currentSkipHoldTime = 0f;
            SkipScenario();
        }
    }

    private void OnDisable()
    {
        //action.Disable();
    }

}
