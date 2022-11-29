using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "ScenarioData", menuName = "TalkSimulator/ScenarioData")]
public class ScenarioData : ScriptableObject
{
    [SerializeField]
    private List<TalkElementData> talkElementDataList;
    public List<TalkElementData> TalkElementDataList { get { return talkElementDataList; } }

    public TalkElementData GetTalkElementData(int index)
    {
        if (index >= talkElementDataList.Count)
            return null;

        return talkElementDataList[index];
    }

}
