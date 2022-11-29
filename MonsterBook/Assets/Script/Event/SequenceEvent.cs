using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceEvent : Event
{
    [Serializable]
    struct EventObj
    {
        public Event eventObj;
        public float time;
    }

    [SerializeField] private EventObj[] events;


    public override void StartEvent()
    {
        StartCoroutine(Routine(0));
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(Routine(time));
    }

    private IEnumerator Routine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        for (int i = 0; i < events.Length; i++)
        {
            events[i].eventObj.StartEvent(events[i].time);
        }
    }

}
