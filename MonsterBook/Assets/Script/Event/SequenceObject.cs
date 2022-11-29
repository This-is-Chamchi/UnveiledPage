using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SequenceObject : Event
{
    [SerializeField] private bool isPlay;
    [SerializeField] private float time;
    [SerializeField] private GameObject[] events;


    private void Start()
    {
        if (isPlay) StartEvent(time);
    }

    public override void StartEvent()
    {
        StartCoroutine(Routine(time));
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
            events[i].SetActive(true);
        }
    }
}
