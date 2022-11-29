using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeDisable : Event
{
    [SerializeField] private bool objActive;

    public override void StartEvent()
    {
        
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(Routine(time));
    }

    private IEnumerator Routine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        for (int i = 0; i < transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(objActive);
        }
    }

}
