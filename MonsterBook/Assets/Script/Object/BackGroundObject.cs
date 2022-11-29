using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class BackGroundObject : MonoBehaviour
{        
    [SerializeField] private Vector2 angle;    
    [SerializeField, Range(1f,5f)] private float speed = 1;
    [SerializeField] private float startTime;

    private bool lookCamera;

    [SerializeField]  private Quaternion start, end;
    private Quaternion startRota;


    void Start()
    {
        var ag = UnityEngine.Random.Range(angle.x, angle.y);
        start = PendulumRotation(ag);
        end = PendulumRotation(-ag);

        startRota = transform.rotation;
    }

    public void StartEvent()
    {
        lookCamera = true;
        StartCoroutine(Routine());
    }

    private IEnumerator Routine()
    {
        while (lookCamera)
        {
            startTime += Time.deltaTime;
            transform.rotation = Quaternion.Lerp(transform.rotation, end, Time.deltaTime * speed);


            if (transform.rotation == end)
            {
                var ag = UnityEngine.Random.Range(angle.x, angle.y);
                var e = end;
                end = PendulumRotation(ag);
                start = e;
            }
            yield return YieldInstructionCache.waitForFixedUpdate;
        }
    }

    void ResetTimer()
    {
        startTime = 0.0f;
    }

    Quaternion PendulumRotation(float angle)
    {
        var pendulumRotation = startRota;
        var angleZ = pendulumRotation.eulerAngles.z + angle;

        if (angleZ > 180)
        {
            angleZ -= 360;
        }
        else if (angleZ < -180)
        {
            angleZ += 360;
        }
        pendulumRotation.eulerAngles = new Vector3(pendulumRotation.eulerAngles.x, pendulumRotation.eulerAngles.y, angleZ);
        return pendulumRotation;

    }

    private void OnTriggerEnter(Collider other)
    {
        StartEvent();   
    }

    private void OnTriggerExit(Collider other)
    {
        lookCamera = false;
    }
}
