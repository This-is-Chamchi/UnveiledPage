using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;

public class WorldLimit : MonoBehaviour
{
    enum Type
    { 
        None,
        Right,
        Left,
    }

    [SerializeField] private Type type;


    private void Start()
    {
        SetLimit();
    }

    private void OnEnable()
    {
        SetLimit();
    }

    private void SetLimit()
    {
        switch (type)
        {
            case Type.None:
                return;
            case Type.Right:
                CameraController.SetCameraLimit(transform.position.x, false);
                break;
            case Type.Left:
                CameraController.SetCameraLimit(transform.position.x, true);
                break;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireCube(transform.position, transform.lossyScale);
    }

    //private void OnDisable()
    //{
    //    switch (type)
    //    {
    //        case Type.None:
    //            return;
    //        case Type.Right:
    //            CameraController.SetCameraLimit(transform.position, false);
    //            break;
    //        case Type.Left:
    //            CameraController.SetCameraLimit(transform.position, true);
    //            break;
    //    }
    //}
}
