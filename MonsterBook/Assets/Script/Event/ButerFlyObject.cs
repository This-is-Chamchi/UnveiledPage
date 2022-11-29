using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ButerFlyObject : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private Transform leftObj;    
    [SerializeField] private Transform rightObj;

    [SerializeField] private Vector3 leftBasic;    

    public float value;

    public void SetRotate(float value)
    {
        transform.localRotation = Quaternion.Euler(new Vector3(0, 0, -value / 2));
        value = transform.localEulerAngles.z;
        leftObj.localRotation = Quaternion.Euler(new Vector3(leftBasic.x, leftBasic.y, leftBasic.z + value));
        rightObj.localRotation = Quaternion.Euler(new Vector3(0, 0, target.localEulerAngles.z - 180));
    }

}
