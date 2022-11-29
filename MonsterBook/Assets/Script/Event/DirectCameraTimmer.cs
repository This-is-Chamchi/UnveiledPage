using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DirectCameraTimmer : Event
{
    [SerializeField] private float holdTime;
    [SerializeField] private float moveSpeed = 4;
    private bool canUse;


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
        CameraController.StartDirectCamera(transform.position, moveSpeed);
        yield return YieldInstructionCache.waitForSeconds(holdTime);
        CameraController.EndDirecCamera();
    }


}
