using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlipObject : MonoBehaviour
{
    [SerializeField] private Transform leftObj;
    [SerializeField] private Transform rightObj;

    [SerializeField] private Vector3 baseEuler;
    [SerializeField] private Vector3 leftBase;
    [SerializeField] private Vector3 rightBase;


    public void SetRotate(float value)
    {
        var rota = value / 2;
        transform.localRotation = Quaternion.Euler(new Vector3(baseEuler.x, baseEuler.y, -rota));
        leftObj.localRotation = Quaternion.Euler(new Vector3(leftBase.x, leftBase.y, leftBase.z - rota));
        rightObj.localRotation = Quaternion.Euler(new Vector3(rightBase.x, rightBase.y, rightBase.z + rota));
    }

}
