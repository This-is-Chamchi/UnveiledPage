using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static UnityEngine.Rendering.DebugUI;

public class FoldBook : Event
{
    enum Axis
    {
        AxisX,
        AxisY,
        AxisZ,
    }

    [Header("[Objects]")]
    [SerializeField] private PercentFoldObject[] foldObjects;

    [Header("[Setting]")]    
    [SerializeField] private bool isPlaying;
    [SerializeField] private Vector3 startEuler;
    [SerializeField] private Vector3 endEuler;
    [SerializeField] private float speed;    


    private void Start()
    {
        transform.localRotation = Quaternion.Euler(startEuler);
        if (isPlaying) StartCoroutine(EventRoutine(0));
        var value = transform.localEulerAngles.z;
        for (int i = 0; i < foldObjects.Length; i++)
        {
            foldObjects[i].SeRotate(value);
        }
    }

    public override void StartEvent()
    {
        
    }

    public override void StartEvent(float time)
    {
        StartCoroutine(EventRoutine(time));
    }

    private IEnumerator EventRoutine(float time)
    {
        yield return YieldInstructionCache.waitForSeconds(time);
        for (int i = 0; i < foldObjects.Length; i++)
        {
            foldObjects[i].SetSee(true);
        }
        while (Quaternion.Angle(transform.localRotation, Quaternion.Euler(endEuler)) > 0.05f)
        {
            transform.localRotation = Quaternion.Lerp(transform.localRotation, Quaternion.Euler(endEuler), Time.deltaTime * speed);
            var value = transform.localEulerAngles.z;
            for (int i = 0; i < foldObjects.Length; i++)
            {
                foldObjects[i].SeRotate(value);
            }

            yield return YieldInstructionCache.waitForFixedUpdate;
        }
    }

         

}
