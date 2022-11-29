using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaperBrunch : Event
{
    [SerializeField] private PaperObject[] paper;
    [SerializeField] private float delay;


    public override void StartEvent()
    {
        StartCoroutine(Routine(delay));
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(Routine(time));
    }

    private IEnumerator Routine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        for (int i = 0; i < paper.Length; i++)
        {
            paper[i].StartEvent();
        }
    }

}
