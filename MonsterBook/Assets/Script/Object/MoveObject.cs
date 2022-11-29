using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveObject : MonoBehaviour
{
    [SerializeField] private Vector3 moveTarget;
    [SerializeField] private float moveSpeed;

    [SerializeField] private bool absolute;
    private Vector3 startPos;
    private bool moving = false;

    private Coroutine startRoutine;
    private Coroutine endRoutine;


    private void Start()
    {
        startPos = transform.position;
        if (!absolute) moveTarget = startPos + moveTarget;
    }

    public void StartMove()
    {
        if (absolute) moveTarget = transform.position + moveTarget;
        if (startRoutine != null) StopCoroutine(startRoutine);
        startRoutine = StartCoroutine(TargetRoutine());
    }

    public void StartMove(float time)
    {
        if (absolute) moveTarget = transform.position + moveTarget;
        if (startRoutine != null) StopCoroutine(startRoutine);
        startRoutine = StartCoroutine(TargetRoutine(time));
    }

    public void EndMove()
    {
        if (endRoutine != null) StopCoroutine(endRoutine);
        endRoutine = StartCoroutine(ReturnRoutine());
    }

    private IEnumerator TargetRoutine()
    {
        moving = true;        
        while (transform.position != moveTarget)
        {
            transform.position = Vector3.MoveTowards(transform.position, moveTarget, Time.deltaTime * moveSpeed);
            if (!moving) break;
            yield return YieldInstructionCache.waitForFixedUpdate;
        }        
    }

    private IEnumerator TargetRoutine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        moving = true;
        while (transform.position != moveTarget)
        {
            transform.position = Vector3.MoveTowards(transform.position, moveTarget, Time.deltaTime * moveSpeed);
            if (!moving) break;
            yield return YieldInstructionCache.waitForFixedUpdate;
        }        
    }

    private IEnumerator ReturnRoutine()
    {
        moving = false;
        
        while (transform.position != startPos)
        {
            transform.position = Vector3.MoveTowards(transform.position, startPos, Time.deltaTime * moveSpeed);
            if (moving) break;
            yield return YieldInstructionCache.waitForFixedUpdate;
        }        
    }
}
