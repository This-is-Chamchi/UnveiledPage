using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FoldingObject : MonoBehaviour
{
    [SerializeField] private bool startFold;
    [SerializeField] private bool foldFront;
    [SerializeField] private float speed;

    private Vector3 standRotation;    
    private Vector3 foldRotation;

    private Coroutine runCoroutine;


    private void Start()
    {
        standRotation = transform.localEulerAngles;
        foldRotation = foldFront ? new Vector3(transform.localRotation.x - 90, transform.localRotation.y, transform.localRotation.z) : new Vector3(transform.localRotation.x + 90, transform.localRotation.y, transform.localRotation.z);

        if (startFold) transform.localEulerAngles = foldRotation;
    }

    public void Fold(bool value)
    {
        if (value)
        {
            if (runCoroutine != null) StopCoroutine(runCoroutine);
            runCoroutine = StartCoroutine(OnRoutine(0));
        }
        else
        {
            if (runCoroutine != null) StopCoroutine(runCoroutine);
            runCoroutine = StartCoroutine(OffRoutine(0));
        }
    }

    public void FoldOn(float time)
    {
        if (runCoroutine != null) StopCoroutine(runCoroutine);
        runCoroutine = StartCoroutine(OnRoutine(time));
    }

    private IEnumerator OnRoutine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        transform.localEulerAngles = foldRotation;        
        while (transform.localEulerAngles != standRotation)
        {
            transform.localEulerAngles = Vector3.Lerp(transform.localEulerAngles, standRotation, Time.deltaTime * speed);
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
    }

    private IEnumerator OffRoutine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        transform.localEulerAngles = standRotation;
        while (transform.localEulerAngles != foldRotation)
        {
            transform.localEulerAngles = Vector3.Lerp(transform.localEulerAngles, foldRotation, Time.deltaTime * speed);
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
    }
}
