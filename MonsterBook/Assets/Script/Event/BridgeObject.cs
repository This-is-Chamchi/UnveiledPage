using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BridgeObject : Event
{
    [SerializeField] private Vector3 startEuler;
    [SerializeField] private Vector3 targetEuler;
    [SerializeField] private float speed;


    private void Start()
    {
        transform.localRotation = Quaternion.Euler(startEuler);
    }

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
        yield return new WaitForSeconds(time);                
        while (transform.localRotation != Quaternion.Euler(targetEuler))
        {
            transform.localRotation = Quaternion.Slerp(transform.localRotation, Quaternion.Euler(targetEuler), Time.deltaTime * speed);            

            yield return YieldInstructionCache.waitForFixedUpdate;
        }
    }

}
