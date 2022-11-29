using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FallObject : Event
{
    [SerializeField] private Rigidbody[] rigid;



    public override void StartEvent()
    {
        StartCoroutine(Routine(0));
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(Routine(time));
    }

    private IEnumerator Routine(float delay)
    {
        GameManager.SetInGameInput(false);
        CameraController.CameraShaking();
        yield return YieldInstructionCache.waitForSeconds(delay);
        for (int i = 0; i < rigid.Length; i++)
        {
            rigid[i].isKinematic = false;
            yield return YieldInstructionCache.waitForSeconds(0.1f);
        }
        GameManager.SetInGameInput(true);
        yield return YieldInstructionCache.waitForSeconds(2f);
        for (int i = 0; i < rigid.Length; i++)
        {
            Destroy(rigid[i].gameObject);
        }
    }


}
