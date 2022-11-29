using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlipWall : MonoBehaviour
{
    [Header("[Wall Value]")]
    [SerializeField] private Transform leftWallObj;
    [SerializeField] private Transform rightWallObj;

    [SerializeField] private Vector3 leftBase;
    [SerializeField] private Vector3 leftTarget;

    [SerializeField] private Vector3 rightBase;
    [SerializeField] private Vector3 rightTarget;

    [Header("[Side Value]")]
    [SerializeField] private Transform leftSideObj;
    [SerializeField] private Transform rightSideObj;

    [SerializeField] private Vector3 sideLeftBase;
    [SerializeField] private Vector3 sideLeftTarget;

    [SerializeField] private Vector3 sideRightBase;
    [SerializeField] private Vector3 sideRightTarget;


    public void SetRotate(float value)
    {
        var v = value / 180f;
        transform.localRotation = Quaternion.Euler(0, 0, -value / 2);
        leftWallObj.localRotation = Quaternion.Lerp(Quaternion.Euler(leftBase), Quaternion.Euler(leftTarget), v);
        rightWallObj.localRotation = Quaternion.Lerp(Quaternion.Euler(rightBase), Quaternion.Euler(rightTarget), v);

        leftSideObj.localRotation = Quaternion.Lerp(Quaternion.Euler(sideLeftBase), Quaternion.Euler(sideLeftTarget), v);
        rightSideObj.localRotation = Quaternion.Lerp(Quaternion.Euler(sideRightBase), Quaternion.Euler(sideRightTarget), v);
    }

}
