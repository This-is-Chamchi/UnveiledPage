using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PercentageFollower : MonoBehaviour
{
    enum Axis
    { 
        AxisX,
        AxisY,
        AxisZ,
    }

    [SerializeField] private Vector3 StartPos;
    [SerializeField] private Vector3 EndPos;

    [SerializeField] private float percent;
    [SerializeField] private Transform target;

    [SerializeField] private Axis axis;


    private void FixedUpdate()
    {
        var v = 0f;
        if (axis == Axis.AxisX) v = target.position.x / percent;
        else if (axis == Axis.AxisY) v = target.position.y / percent;
        else if (axis == Axis.AxisZ) v = target.position.z / percent;

        transform.localPosition = Vector3.Lerp(StartPos, EndPos, v);   
    }

}
