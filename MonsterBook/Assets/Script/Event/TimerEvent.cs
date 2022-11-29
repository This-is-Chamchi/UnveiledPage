using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimerEvent : MonoBehaviour
{
    [Serializable]
    struct EventObj
    {
        public Event eventObj;
        public float time;
    }
    [SerializeField] private bool isStart;
    [SerializeField] private float startTime;
    [SerializeField] private EventObj[] events;


    private void Start()
    {
        if (isStart) StarEvents(startTime);
    }

    public void StarEvents()
    {
        StartCoroutine(Routine(0));
    }

    public void StarEvents(float time)
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
